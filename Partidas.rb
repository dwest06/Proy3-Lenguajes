=begin
    Manejador de Partidas    
=end
module Partidas

    # Modulo de Estrategias
    require './Estrategias.rb'
    
    # Clase Partida, Controla las posibles partidas del juego
    class Partida

        # Jugadores y sus Estrategias
        attr_reader :jugadores

        # Nombre de la ronda para los resultados
        attr_reader :round_name

        # Resultados
        attr_reader :resultados

        # Jugada de la Ronda Anterior
        attr_reader :prev_play

        def initialize(jugadores)

            if ! jugadores.kind_of?(Hash)
                raise ArgumentError, "La Partida necesita un Hash de dos jugadores y sus Estrategias"
            end

            if jugadores.length != 2
                raise ArgumentError, "La Partida necesita un Hash de dos jugadores y sus Estrategias"
            end
            
            @jugadores = jugadores.clone

            @jugadores.keys.each { |k|

                if k.class != Symbol
                    raise RuntimeError , "Error, El jugador #{k} no tiene un nombre valido, solo se aceptan simbolos" 
                end

                if !(@jugadores[k].class <= Estrategias::Estrategia)
                    raise RuntimeError , "Error, La Estrategia \"#{@jugadores[k].to_s}\" de #{k} no es una Estrategia Valida" 
                end
                if @jugadores[k].class == Estrategias::Estrategia
                    raise RuntimeError , "Error, La Estrategia \"#{@jugadores[k].to_s}\" de #{k} no es una Estrategia suficientemente instanciada" 
                end
            }

            @round_name = :Rounds

            while (@jugadores.key?(@round_name)) do
                @round_name = (@round_name.to_s + "_").to_sym
            end
            
            @resultados = {}
            @prev_play = {}

            reiniciar()
        end

        # Reinicia el estado de la partida
        def reiniciar
            @jugadores.keys.each { |k|
                @jugadores[k].reset
                @resultados[k] = 0
                @prev_play[k] = nil
            }

            @resultados[@round_name] = 0
        end

        # Jugar una ronda
        def ronda
            p1 = @jugadores.keys[0]
            p2 = @jugadores.keys[1]

            r1 = @jugadores[p1].prox(@prev_play[p2])
            r2 = @jugadores[p2].prox(@prev_play[p1])

            puntos = r1.puntos(r2)
            
            @resultados[p1] += puntos[0]
            @resultados[p2] += puntos[1]

            @prev_play[p1] = r1
            @prev_play[p2] = r2

            @resultados[@round_name] += 1

            return @resultados
        end

        # Revisar si una variable es un entero positivo
        def self.check_positive_int(n)
            return n.is_a?(Integer) && n > 0
        end

        # Jugar n rondas, siendo n un numero positivo. 
        #   Devuelve los resultados de jugar las rondas en un Hash
        def rondas(n)
            if ! Partida.check_positive_int(n)
                raise ArgumentError, "Error \"#{n.to_s}\" no es un entero positivo requerido para jugar Rondas" 
            end

            n.times {|x|
                ronda()
            }

            return @resultados.clone
        end

        # Jugar hasta que un jugador tenga n puntos, siendo n un numero positivo. 
        #   Devuelve los resultados de jugar las rondas en un Hash
        # Peligro, existen combinaciones de estrategias (indecidibles de saber) que pueden hacer 
        #   que quede en loop infinito. Ej: 2 Copiar con el mismo inicio
        def alcanzar(n)
            if ! Partida.check_positive_int(n)
                raise ArgumentError, "Error \"#{n.to_s}\" no es un entero positivo requerido para jugar Alcanzar" 
            end

            p1 = @jugadores.keys[0]
            p2 = @jugadores.keys[1]

            while true
                if @resultados[p1] >= n || @resultados[p2] >= n
                    break
                end
                ronda()
            end

            return @resultados.clone
        end
    end
end