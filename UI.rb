

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
    
    # Genera las opciones de la estrategia uniforme
    def generate_uniform_options()
        @players_jugadas.keys.map do |name|
            flow { @c = check; para name }
            [@c, name]
        end
    end

    # Dado una lista con la forma [[check,name]] se obtienen las opciones de la estrategia uniforme seleccionada
    def get_uniform_options(contenedor)
        contenedor.map { |c, name| @players_jugadas[name] if c.checked? }.compact 
    end

    # P1 GUI
    @p1_estrategia_selector = nil
    @p1_estrategia = nil
    @p1_strategy_stack = nil
    @p1_uniform_options = [] # [[check,name]

    # P2 GUI
    @p2_estrategia_selector = nil
    @p2_estrategia = nil
    @p2_strategy_stack = nil
    @p2_uniform_options = [] # [(check,name)]
    
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
                        width: 120, choose: @players_estrategias.keys[0] do |list|
                        @p1_estrategia.text = "Estrategia #{list.text} Selecionada"

                        curr_estrategia = @players_estrategias[list.text]

                        @p1_strategy_stack.hidden = curr_estrategia == :Pensar || curr_estrategia == :Manual
                        @p1_strategy_stack.clear()
                        if !@p1_strategy_stack.hidden
                            @p1_strategy_stack.append do
                                subtitle("Configurar Estrategia", size: "small", weight: "bold") 
                                if curr_estrategia == :Uniforme
                                    @p1_uniform_options = generate_uniform_options() 
                                end
                            end
                        end
                    end
                    @p1_estrategia = para "Estrategia no seleccionada"
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
                        width: 120, choose: @players_estrategias.keys[0] do |list|
                        @p2_estrategia.text = "Estrategia #{list.text} Selecionada"

                        curr_estrategia = @players_estrategias[list.text]

                        @p2_strategy_stack.hidden = curr_estrategia == :Pensar || curr_estrategia == :Manual
                        @p2_strategy_stack.clear()
                        if !@p2_strategy_stack.hidden
                            @p2_strategy_stack.append do
                                subtitle("Configurar Estrategia", size: "small", weight: "bold") 
                                if curr_estrategia == :Uniforme
                                    @p2_uniform_options = generate_uniform_options() 
                                end
                            end
                        end
                    end
                    @p2_estrategia = para "Estrategia no seleccionada"
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

    @iniciar_juego.click {
        # Iniciar Juego
        @juego_iniciado = true
        @reiniciar_juego.state = nil
        @detener_juego.state = nil
        @p1_estrategia_selector.state = "disabled" 
        @p2_estrategia_selector.state = "disabled" 
    }

    @detener_juego.click {
        # Terminar Juego
        @juego_iniciado = false
        @reiniciar_juego.state = "disabled" 
        @detener_juego.state = "disabled"
        @p1_estrategia_selector.state = nil 
        @p2_estrategia_selector.state = nil 
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