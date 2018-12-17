=begin
    Manejador de Estrategias    
=end
module Estrategias

    # Modulo de Jugadas
    require './Jugadas.rb'

    # Clase Estrategia, Controla las posibles estrategias del juego
    class Estrategia

        # Semilla para los RNG
        SEED = 42

        # Representacion string de una Estrategia
        def to_s()
            "Estrategia"
        end
        
        # Generar Proxima Jugada. Donde se recibe una Jugada para su posible utilizacion en la generacion
        # de la siguiente Jugada.
        def prox(m)
            if m == nil
                return
            end

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

        # Representacion string de una Estrategia Manual
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

        # Constructor de Estrategia Uniforme. Recibe una lista de Movimientos validos para usar
        def initialize(movimientos)

            if ! movimientos.kind_of?(Array)
                raise ArgumentError, "La Estrategia Uniforme necesita una lista no vacia de movimientos validos para instanciarse"
            end

            @movimientos = movimientos.clone

            @movimientos.uniq!

            @movimientos = @movimientos.reduce([]) do |acc, s|
                jugada = Jugadas.symbol_to_jugada(s)
                if jugada != nil
                  acc << jugada
                end
                acc
            end

            if @movimientos.length == 0
                raise ArgumentError, "La Estrategia Uniforme necesita una lista no vacia de movimientos validos para instanciarse"
            end

            reset()
        end

        # Representacion string de una Estrategia Uniforme
        def to_s()
            "#{super()} Uniforme"
        end

        # Generar Proxima Jugada. Donde se recibe una Jugada para su posible utilizacion en la generacion
        # de la siguiente Jugada.
        def prox(m)
            super(m)
            @movimientos.sample(1, random: @rng)[0]
        end

        # Lleva la Estrategia Uniforme a su estado inicial de rng
        def reset()
            @rng = Random.new(SEED)
        end
    end

    # Clase Estrategia Sesgada
    class Sesgada < Estrategia

        # Movimientos para generar sesgadamente
        attr_reader :movimientos

        # Constructor de Estrategia Sesgada. Recibe un Hash de los posibles movimientos y sus probabilidades
        def initialize(movimientos)

            if ! movimientos.kind_of?(Hash)
                raise ArgumentError, "La Estrategia Sesgada necesita un Hash no vacia de movimientos validos y sus probabilidades para instanciarse"
            end

            @movimientos = movimientos.clone

            acc = 0  
            # Eliminar lo que no sirve y guardar suma total
            @movimientos.keys.each { |k|
                jugada = Jugadas.symbol_to_jugada(k)
                if @movimientos[k].is_a?(Numeric) && jugada != nil && @movimientos[k] > 0
                    @movimientos[jugada] = @movimientos[k]
                    acc += @movimientos[jugada] 
                end
                @movimientos.delete(k) 
            }

            if @movimientos.length == 0
                raise ArgumentError, "La Estrategia Sesgada necesita un Hash no vacia de movimientos validos y sus probabilidades para instanciarse"
            end

            # Normalizar
            @movimientos.keys.each { |k|
                @movimientos[k] = @movimientos[k] / acc
            }

            reset()
        end

        # Representacion string de una Estrategia Sesgada
        def to_s()
            "#{super()} Sesgada"
        end

        # Generar Proxima Jugada. Donde se recibe una Jugada para su posible utilizacion en la generacion
        # de la siguiente Jugada.
        def prox(m)
            super(m)
            prob = @rng.rand(1.0)
            movimientos.keys.each { |k|
                return k if prob <= movimientos[k]
                prob -= movimientos[k]
            }
        end

        # Lleva la estrategia a su estado inicial de rng
        def reset()
            @rng = Random.new(SEED)
        end
    end

    # Pruebas de Estrategias
    def Estrategias.test_estrategias()
        require './UserInput.rb'

        begin
            m = Manual.new(UserInput.from_console)
            puts m.prox(Jugadas::Piedra.new)
            puts "Estrategia Manual Funciona"
        rescue => exception
            puts "Error con Estrategia Manual"
            puts exception
            return false
        end

        puts ""

        begin
            u = Uniforme.new([])
            puts "Error Creando Estrategia Uniforme"
            return false
        rescue => exception
            puts exception
            puts "Estrategia Uniforme Funciona con argumento []"
        end

        puts ""

        arg = [:arg, :wtf, 4, :s, "asdasd", nil]
        begin
            u = Uniforme.new(arg)
            puts "Error Creando Estrategia Uniforme con: #{arg}"
            return false
        rescue => exception
            puts exception
            puts "Estrategia Uniforme Funciona con: #{arg}"
        end

        puts ""
        
        arg = [:Piedra, :wtf, 4, :Lagarto, :Piedra]
        begin
            u = Uniforme.new(arg)
            if !(u.movimientos[0].is_a?(Jugadas::Piedra))
                raise RuntimeError, "No se encontro Piedra en #{u.movimientos}"
            end
            if (!(u.movimientos[1].is_a?(Jugadas::Lagarto)))
                raise RuntimeError, "No se encontro Lagarto en #{u.movimientos}"
            end
            puts "Estrategia Uniforme Funciona con: #{arg}"
            puts "Dando como Movimientos: #{u.movimientos}"
        rescue => exception
            puts exception
            puts "Error Creando Estrategia Uniforme con: #{arg}"
            return false
        end

        puts ""
        
        arg = {}
        begin
            s = Sesgada.new(arg)
            puts "Estrategia Sesgada No Funciona con: #{arg}"
            return false
        rescue => exception
            puts exception
            puts "Estrategia Sesgada Funciona con: #{arg}"
        end

        puts ""
        
        arg = {:Piedra => :Piedra, 4 => 3, :Lagarto => -1, :Spock => 0}
        begin
            s = Sesgada.new(arg)
            puts "Estrategia Sesgada No Funciona con: #{arg}"
            return false
        rescue => exception
            puts exception
            puts "Estrategia Sesgada Funciona con: #{arg}"
        end

        puts ""

        arg = {:Piedra => 1, :Lagarto => 1.4, :Spock => 3}
        begin
            s = Sesgada.new(arg)
            puts "Estrategia Sesgada Funciona con: #{arg}"
            puts s.movimientos
        rescue => exception
            puts exception
            puts "Estrategia Sesgada No Funciona con: #{arg}"
            return false
        end
        
        return true
    end

end