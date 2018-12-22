
require './Partidas.rb'

Shoes.app(title: "Piedra, Papel, Tijeras, Lagarto, Spock") {

    background("#EFC")
    border("#BE8", strokewidth: 6)
    
    # General Config
    @players_background = "#FF9499"
    @players_border = "#FF5253"
    @players_estrategias = {
        "Manual" => :Manual, "Uniforme" => :Uniforme, 
        "Sesgada"  => :Sesgada, "Copiar"  => :Copiar, "Pensar" => :Pensar}
    @players_jugadas = {
        "Piedra" => :Piedra, "Papel" => :Papel, 
        "Tijera" => :Tijera, "Lagarto" => :Lagarto, "Spock" => :Spock}

    # P1 GUI
    @p1_player_name = :P1
    @p1_estrategia_selector = nil
    @p1_estrategia_text = nil
    @p1_estrategia = nil # Symbol
    @p1_strategy_stack = nil
    @p1_uniform_options = [] # [[check,name]]
    @p1_bias_options = [] # [[check,name,n_text]]
    @p1_copy_options = nil # list_box

    # P2 GUI
    @p2_player_name = :P2
    @p2_estrategia_selector = nil
    @p2_estrategia_text = nil
    @p2_estrategia = nil # Symbol
    @p2_strategy_stack = nil
    @p2_uniform_options = [] # [[check,name]]
    @p2_bias_options = [] # [[check,name,n_text]]
    @p2_copy_options = nil # list_box

    # Manual Config
    @manual_ready = :Ready
    @manual_buttons = :Buttons
    @manual_option = :Option 
    @manual_callback = :Callback 
    @manual_options = {@p1_player_name => nil, @p2_player_name => nil}
    @manual_player_string_name = {@p1_player_name => "Jugador 1", @p2_player_name => "Jugador 2"}.freeze

    # Prop de juego
    @juego_iniciado = false
    @juego_partida = nil
    @juego_manuales = []

    # UI de Juego
    @iniciar_juego = nil
    @reiniciar_juego = nil
    @detener_juego = nil
    
    # Revisa un string y solo deja los caracteres validos de un float sin signo
    def check_float(t) 
        t.gsub(/[^\d\.]+/, '').squeeze(".")
        dot_acc = 0
        for i in 0...(t.length) do
            if t[i] == '.'
                if dot_acc >= 1
                    t[i] = ''
                end
                dot_acc += 1
            end
        end
        return t
    end
    
    # Genera las opciones de la estrategia uniforme
    def generate_uniform_options()
        checks = @players_jugadas.keys.map do |name|
            flow { c = check; para name }
            [c, name]
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
            flow { c = check; para name; n = edit_line "1.0", width: 100, margin: 4, align: "center";}
            n.change { |t|
                t.text = check_float(t.text()) 
            }
            [c, name, n]
        end
        para "Se tiene que seleccionar por lo menos una opcion. Se necesita una opcion con probabilidad mayor a cero", size: "xx-small"
        return checks
    end

    # Dado una lista con la forma [[check,name,n_text]] se obtienen las opciones de la estrategia sesgada 
    # seleccionada
    def get_bias_options(contenedor)
        contenedor.reduce({}) { |acc, res| 
            num = res[2].text().to_f().abs()
            if res[0].checked? && num > 0 
                acc[@players_jugadas[res[1]]] = num 
            end
            acc
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

    # Genera las opciones de Estrategia Manual de un Jugador
    def generate_manual_options(player_name) 
        @manual_options[player_name] = {}
        @manual_options[player_name][@manual_ready] = false
        @manual_options[player_name][@manual_option] = nil

        @manual_options[player_name][@manual_callback] = lambda { 
            return Jugadas.symbol_to_jugada(@manual_options[player_name][@manual_option])
        }

        @manual_options[player_name][@manual_buttons] = @players_jugadas.keys.map { |name|
            b = button name, state: "disabled", margin_left: 4, width: 120
            b.click {
                @manual_options[player_name][@manual_option] = @players_jugadas[name]
            }
            b
        }

        aceptar = button "Aceptar Jugada", state: "disabled", margin_left: 4, width: 200
        aceptar.click {
            if get_manual_option(player_name) != nil
                state_manual_options(player_name, "disabled")
                @manual_options[player_name][@manual_ready] = true
            else
                alert "#{@manual_player_string_name[player_name]} no ha seleccionado una opcion para jugar"
            end
        }

        @manual_options[player_name][@manual_buttons] << aceptar
        para "Opciones de Estrategia Manual estan activas durante el juego. Para seleccionar una Jugada, "\
            "darle al boton y luego a Aceptar Jugada", size: "xx-small"
    end

    # Obtener la opcion manual seleccionada por jugador
    def get_manual_option(player_name) 
        @manual_options[player_name][@manual_option]
    end

    # Obtener el callback manual de un jugador
    def get_manual_callback(player_name) 
        @manual_options[player_name][@manual_callback]
    end

    # Obtener el estatus de ready manual de un jugador
    def get_manual_ready(player_name) 
        @manual_options[player_name][@manual_ready]
    end

    # Cambiar el estado de las opciones de estrategia manual
    def state_manual_options(player_name, state)
        @manual_options[player_name][@manual_buttons].each { |btn|
            btn.state = state
        }
    end

    # Cambiar el estado de estrategia manual a no seleccionado
    def reset_manual_option(player_name)
        @manual_options[player_name][@manual_option] = nil
    end

    # Revisa Si los jugadores aplicaron sus jugadas manuales en caso de haber
    def check_manuals_ready()
        @juego_manuales.all? { |player_name|
            get_manual_ready(player_name) 
        }
    end

    # Reinicia la seleccion manual de los jugadores luego de una ronda
    def reset_manuals_ready()
        @juego_manuales.each { |player_name|
            reset_manual_option(player_name)
            state_manual_options(player_name, nil)
        }
    end

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

                        @p1_strategy_stack.hidden = @p1_estrategia == :Pensar
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
                                    when :Manual
                                        generate_manual_options(@p1_player_name)
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

                        @p2_strategy_stack.hidden = @p2_estrategia == :Pensar
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
                                    when :Manual
                                        generate_manual_options(@p2_player_name)
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
            @iniciar_juego = button "Iniciar Partida", width: '33%'
            @detener_juego = button "Detener Partida", width: '33%'
            @reiniciar_juego = button "Reiniciar Partida", width: '33%'
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
            when :Manual
                state_manual_options(@p1_player_name, "disabled") 
                reset_manual_option(@p1_player_name) 
        end

        case @p2_estrategia
            when :Uniforme
                state_uniform_options(@p2_uniform_options, nil) 
            when :Sesgada
                state_bias_options(@p2_bias_options, nil)
            when :Copiar
                state_copy_options(@p2_copy_options, nil) 
            when :Manual
                state_manual_options(@p2_player_name, "disabled")  
                reset_manual_option(@p2_player_name) 
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

        @juego_manuales = []
        partida_args = {}
        case @p1_estrategia
            when :Uniforme
                state_uniform_options(@p1_uniform_options, "disabled")
                partida_args[@p1_player_name] = Estrategias::Uniforme.new(get_uniform_options(@p1_uniform_options))
            when :Sesgada
                state_bias_options(@p1_bias_options, "disabled")
                partida_args[@p1_player_name] = Estrategias::Sesgada.new(get_bias_options(@p1_bias_options))
            when :Copiar
                state_copy_options(@p1_copy_options, "disabled")
                partida_args[@p1_player_name] = Estrategias::Copiar.new(get_copy_options(@p1_copy_options))
            when :Manual
                state_manual_options(@p1_player_name, nil)
                partida_args[@p1_player_name] = Estrategias::Manual.new(get_manual_callback(@p1_player_name))
                @juego_manuales <<  @p1_player_name
            when :Pensar
                partida_args[@p1_player_name] = Estrategias::Pensar.new
        end
        
        case @p2_estrategia
            when :Uniforme
                state_uniform_options(@p2_uniform_options, "disabled") 
                partida_args[@p2_player_name] = Estrategias::Uniforme.new(get_uniform_options(@p2_uniform_options))
            when :Sesgada
                state_bias_options(@p2_bias_options, "disabled")
                partida_args[@p2_player_name] = Estrategias::Sesgada.new(get_bias_options(@p2_bias_options)) 
            when :Copiar
                state_copy_options(@p2_copy_options, "disabled") 
                partida_args[@p2_player_name] = Estrategias::Copiar.new(get_copy_options(@p2_copy_options))
            when :Manual
                state_manual_options(@p2_player_name, nil) 
                partida_args[@p2_player_name] = Estrategias::Manual.new(get_manual_callback(@p2_player_name))
                @juego_manuales <<  @p2_player_name
            when :Pensar
                partida_args[@p2_player_name] = Estrategias::Pensar.new   
        end

        @juego_partida = Partidas::Partida.new(partida_args)
        @juego_iniciado = true
        @iniciar_juego.state = "disabled" 
        @reiniciar_juego.state = nil
        @detener_juego.state = nil
        @p1_estrategia_selector.state = "disabled"  
        @p2_estrategia_selector.state = "disabled"  
    end

    @iniciar_juego.click {
        iniciar_juego()
    }

    @detener_juego.click {
        terminar_juego()
    }
   
}