=begin
    Manejador de Estrategias    
=end
module Estrategias
    # Modulo de Jugadas
    require './Jugadas.rb'

    # Clase Estrategia, Controla las posibles estrategias del juego
    class Estrategia
        # Representacion string de una Jugada
        def to_s()
            "Estrategia"
        end
        
        # Generar Proxima Jugada. Donde se recibe una Jugada para su posible utilizacion en la generacion
        # de la siguiente Jugada.
        def prox(m)
            if !(m.class <= Jugadas::Jugada)
                raise ArgumentError, "Error \"#{m.to_s}\" no es una Jugada Valida" 
            end
            if m.class == Jugadas::Jugada
                raise ArgumentError, "Error \"#{m.to_s}\" no es una Jugada suficientemente instanciada" 
            end
        end

        # Lleva la estrategia a su estado inicial, cuando esto tenga sentido
        def reset()
        end
    end

    # Clase Estrategia Manual
    class Manual < Estrategia

        # Manejador de Input de Usuario
        attr_accessor :callback

        # Constructor de Estrategia Manual. Recibe un callback que no tome argumentos y retorne una jugada
        def initialize(callback)
            @callback = callback
        end

        # Representacion string de una Jugada
        def to_s()
            "#{super()} Manual"
        end

        # Generar Proxima Jugada. Donde se recibe una Jugada para su posible utilizacion en la generacion
        # de la siguiente Jugada.
        def prox(m)
            super(m)
            begin
                res = @callback.call()
                if !(res.class <= Jugadas::Jugada)
                    raise RuntimeError , "Error de Callback, \"#{res.to_s}\" no es una Jugada Valida" 
                end
                if res.class == Jugadas::Jugada
                    raise RuntimeError , "Error de Callback, \"#{res.to_s}\" no es una Jugada suficientemente instanciada" 
                end
                return res
            rescue => exception
                puts "Error en llamada a Callback de #{self}"
                puts exception
            end
        end
    end

    # Clase Estrategia Uniforme
    class Uniforme < Estrategia

        # Movimientos para generar uniformemente
        attr_reader :movimientos

        # Constructor de Estrategia Manual. Recibe un callback que no tome argumentos y retorne una jugada
        def initialize(movimientos)

            if ! movimientos.kind_of?(Array)
                raise ArgumentError, "La Estrategia Uniforme necesita una lista no vacia de movimientos validos para instanciarse"
            end

            movimientos.uniq!

            @movimientos = movimientos.reduce([]) do |acc, s|
                jugada = Jugadas.symbol_to_jugada(s)
                if jugada != nil
                  acc << jugada
                end
                acc
            end

            if @movimientos.length == 0
                raise ArgumentError, "La Estrategia Uniforme necesita una lista no vacia de movimientos validos para instanciarse"
            end
        end

        # Representacion string de una Jugada
        def to_s()
            "#{super()} Uniforme"
        end

        # Generar Proxima Jugada. Donde se recibe una Jugada para su posible utilizacion en la generacion
        # de la siguiente Jugada.
        def prox(m)
            super(m)
            @movimientos.sample
        end
    end

end