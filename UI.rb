

Shoes.app(title: "Piedra, Papel, Tijeras, Lagarto, Spock") {

    background "#EFC"
    border("#BE8",
           strokewidth: 6)
    
    # General Config
    @players_background = "#FF9499"
    @players_border = "#FF5253"
    @players_estrategias = {
        "Manual" => :Manual, "Uniforme" => :Uniforme, 
        "Sesgada"  => :Sesgada, "Copiar"  => :Copiar, "Pensar" => :Pensar}
    @players_jugadas = {
        "Piedra" => :Piedra, "Papel" => :Papel, 
        "Tijera" => :Tijera, "Lagarto" => :Lagarto, "Spock" => :Spock}
    
    # Revisa un string y solo deja los caracteres validos de un float sin signo
    def check_float(t) 
        t.gsub(/[^\d\.]+/, '').squeeze(".")
    end
    
    # Genera las opciones de la estrategia uniforme
    def generate_uniform_options()
        checks = @players_jugadas.keys.map do |name|
            flow { @c = check; para name }
            [@c, name]
        end
        para "Se tiene que seleccionar por lo menos una opcion", size: "xx-small"
        return checks
    end

    # Dado una lista con la forma [[check,name]] se obtienen las opciones de la estrategia uniforme 
    # seleccionada
    def get_uniform_options(contenedor)
        contenedor.map { |c, name| @players_jugadas[name] if c.checked? }.compact 
    end

    # Cambiar el estado de las opciones de estrategia uniforme
    def state_uniform_options(contenedor, state)
        contenedor.each { |c, name| c.state = state }
    end

    # Revisar si la estrategia uniforme tiene un estado valido
    def check_uniform_options(contenedor, jugador)
        res = contenedor.any? { |c, name|
            c.checked?
        } 
        if !res
            alert "La Estrategia Uniforme del #{jugador} no es valida, tiene que seleccionarse una opcion"
        end
        return res
    end

    # Genera las opciones de la estrategia sesgada
    def generate_bias_options()
        checks = @players_jugadas.keys.map do |name|
            flow { @c = check; para name; @n = edit_line "1.0", width: 100, margin: 4, align: "center";}
            @n.change { |t|
                s = check_float(t.text()) 
                dot_acc = 0
                for i in 0...(s.length) do
                    if s[i] == '.'
                        if dot_acc >= 1
                            s[i] = ''
                        end
                        dot_acc += 1
                    end
                end
                t.text = s
            }
            [@c, name, @n]
        end
        para "Se tiene que seleccionar por lo menos una opcion. Se necesita una opcion con probabilidad mayor a cero", size: "xx-small"
        return checks
    end

    # Dado una lista con la forma [[check,name,n_text]] se obtienen las opciones de la estrategia sesgada 
    # seleccionada
    def get_bias_options(contenedor)
        contenedor.reduce({}) { |acc, res| 
            num = res[2].text().to_f().abs()
            acc[@players_jugadas[res[1]]] = num if res[0].checked? && num > 0 
        }
    end

    # Cambiar el estado de las opciones de estrategia sesgada
    def state_bias_options(contenedor, state)
        contenedor.each { |c, name, n| c.state = state;  n.state = state;}
    end

    # Revisar si la estrategia sesgada tiene un estado valido
    def check_bias_options(contenedor, jugador)
        res = contenedor.any? { |c, name, n|
            c.checked?() && n.text().to_f().abs() > 0
        } 
        if !res
            alert "La Estrategia Sesgada del #{jugador} no es valida, tiene que seleccionarse una opcion y tiene que tener probabilidad mayor a cero"
        end
        return res
    end

    # Genera las opciones de la estrategia copiar
    def generate_copy_options()
        res = list_box items: @players_jugadas.keys,
            width: 120, choose: @players_jugadas.keys[0], margin_left: 4
            para "Se tiene que seleccionar una opcion como la jugada inicial", size: "xx-small"
        return res
    end

    # Obtiene la jugada inicial de la estrategia copiar
    def get_copy_options(list_b)
        @players_jugadas[list_b.text()]
    end

    # Cambiar el estado de las opciones de estrategia copiar
    def state_copy_options(list_b, state)
        list_b.state = state
    end

    # Revisar si la estrategia copiar tiene un estado valido
    def check_copy_options(list_b, jugador)
        res = list_b.text != nil 
        if !res
            alert "La Estrategia Copiar del #{jugador} no es valida, tiene que seleccionarse una opcion y tiene que tener probabilidad mayor a cero"
        end
        return res
    end

    # P1 GUI
    @p1_estrategia_selector = nil
    @p1_estrategia_text = nil
    @p1_estrategia = nil # Symbol
    @p1_strategy_stack = nil
    @p1_uniform_options = [] # [[check,name]]
    @p1_bias_options = [] # [[check,name,n_text]]
    @p1_copy_options = nil # list_box

    # P2 GUI
    @p2_estrategia_selector = nil
    @p2_estrategia_text = nil
    @p2_estrategia = nil # Symbol
    @p2_strategy_stack = nil
    @p2_uniform_options = [] # [[check,name]]
    @p2_bias_options = [] # [[check,name,n_text]]
    @p2_copy_options = nil # list_box
    
    # Prop de juego
    @juego_iniciado = false

    # UI de Juego
    @iniciar_juego = nil
    @reiniciar_juego = nil
    @detener_juego = nil

    # Control Central
    stack(margin: 6, width: '100%', height: '100%') do
        flow do
            # Izquierda
            stack :width => '50%', :margin => 6 do
                background @players_background
                border(@players_border, strokewidth: 6)
                stack(margin: 6) do
                    title "Jugador 1"
                    subtitle("Seleccionar Estrategia", size: "small", weight: "bold")
                    @p1_estrategia_selector = list_box items: @players_estrategias.keys,
                        width: 120, choose: @players_estrategias.keys[0], margin_left: 4 do |list|
                        @p1_estrategia_text.text = "Estrategia #{list.text} Selecionada"

                        @p1_estrategia = @players_estrategias[list.text]

                        @p1_strategy_stack.hidden = @p1_estrategia == :Pensar || @p1_estrategia == :Manual
                        @p1_strategy_stack.clear()
                        if !@p1_strategy_stack.hidden
                            @p1_strategy_stack.append do
                                subtitle("Configurar Estrategia", size: "small", weight: "bold") 
                                case @p1_estrategia
                                    when :Uniforme
                                        @p1_uniform_options = generate_uniform_options()
                                    when :Sesgada
                                        @p1_bias_options = generate_bias_options()
                                    when :Copiar
                                        @p1_copy_options = generate_copy_options()
                                end 
                            end
                        end
                    end
                    @p1_estrategia_text = para "Estrategia no seleccionada"
                    @p1_strategy_stack = stack(hidden: true) { }
                end
            end
            # Derecha
            stack :width => '50%', :align => "right", :margin => 6 do
                background @players_background
                border(@players_border, strokewidth: 6)
                stack(margin: 6) do
                    title "Jugador 2"
                    subtitle("Seleccionar Estrategia", size: "small", weight: "bold")
                    @p2_estrategia_selector = list_box items: @players_estrategias.keys,
                        width: 120, choose: @players_estrategias.keys[0], margin_left: 4 do |list|
                        @p2_estrategia_text.text = "Estrategia #{list.text} Selecionada"

                        @p2_estrategia = @players_estrategias[list.text]

                        @p2_strategy_stack.hidden = @p2_estrategia == :Pensar || @p2_estrategia == :Manual
                        @p2_strategy_stack.clear()
                        if !@p2_strategy_stack.hidden
                            @p2_strategy_stack.append do
                                subtitle("Configurar Estrategia", size: "small", weight: "bold") 
                                case @p2_estrategia
                                    when :Uniforme
                                        @p2_uniform_options = generate_uniform_options()
                                    when :Sesgada
                                        @p2_bias_options = generate_bias_options()
                                    when :Copiar
                                        @p2_copy_options = generate_copy_options()
                                end 
                            end
                        end
                    end
                    @p2_estrategia_text = para "Estrategia no seleccionada"
                    @p2_strategy_stack = stack(hidden: true) { }
                end
            end
        end
        flow :margin => 6, :width => '100%' do
            @iniciar_juego = button "Iniciar Partida"
            @detener_juego = button "Detener Partida"
            @reiniciar_juego = button "Reiniciar Partida"
        end
    end

    @reiniciar_juego.state = "disabled"
    @detener_juego.state = "disabled"

    # Terminar el juego
    def terminar_juego()
        # Terminar Juego
        @juego_iniciado = false
        @iniciar_juego.state = nil
        @reiniciar_juego.state = "disabled" 
        @detener_juego.state = "disabled"
        @p1_estrategia_selector.state = nil 
        @p2_estrategia_selector.state = nil 

        case @p1_estrategia
            when :Uniforme
                state_uniform_options(@p1_uniform_options, nil) 
            when :Sesgada
                state_bias_options(@p1_bias_options, nil)
            when :Copiar
                state_copy_options(@p1_copy_options, nil) 
        end

        case @p2_estrategia
            when :Uniforme
                state_uniform_options(@p2_uniform_options, nil) 
            when :Sesgada
                state_bias_options(@p2_bias_options, nil)
            when :Copiar
                state_copy_options(@p2_copy_options, nil) 
        end

    end

    # Iniciar el juego
    def iniciar_juego()
        check_p1 = true
        case @p1_estrategia
            when :Uniforme
                check_p1 = check_uniform_options(@p1_uniform_options, "Jugador 1") 
            when :Sesgada
                check_p1 = check_bias_options(@p1_bias_options, "Jugador 1")
            when :Copiar
                check_p1 = check_copy_options(@p1_copy_options, "Jugador 1")
        end

        check_p2 = true
        case @p2_estrategia
            when :Uniforme
                check_p2 = check_uniform_options(@p2_uniform_options, "Jugador 2") 
            when :Sesgada
                check_p2 = check_bias_options(@p2_bias_options, "Jugador 2")
            when :Copiar
                check_p2 = check_copy_options(@p2_copy_options, "Jugador 2")
        end

        if !check_p1 || !check_p2
            return;
        end

        @juego_iniciado = true
        @iniciar_juego.state = "disabled" 
        @reiniciar_juego.state = nil
        @detener_juego.state = nil
        @p1_estrategia_selector.state = "disabled"  
        @p2_estrategia_selector.state = "disabled"  

        case @p1_estrategia
            when :Uniforme
                state_uniform_options(@p1_uniform_options, "disabled") 
            when :Sesgada
                state_bias_options(@p1_bias_options, "disabled")
            when :Copiar
                state_copy_options(@p1_copy_options, "disabled")      
        end
        
        case @p2_estrategia
            when :Uniforme
                state_uniform_options(@p2_uniform_options, "disabled") 
            when :Sesgada
                state_bias_options(@p2_bias_options, "disabled") 
            when :Copiar
                state_copy_options(@p2_copy_options, "disabled") 
        end
    end

    @iniciar_juego.click {
        iniciar_juego()
    }

    @detener_juego.click {
        terminar_juego()
    }
    

    

    
    
}

=begin 
@wtf ||= false

@shape = star(points: 5)
motion do |left, top|
    @shape.move left, top
end
@push = button "Push me"
@note = para "Nothing pushed so far"
@push.click {
    @wtf = !@wtf
    @note.replace "Aha! Click! #{@wtf}"
}
if @wtf 
    @note2 = para "Test"
end
=end