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
            "#{super()} Manual con callback=#{@callback}"
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
            "#{super()} Uniforme con movimientos=#{@movimientos} y rng=#{@rng}"
        end

        # Generar Proxima Jugada. Donde se recibe una Jugada para su posible utilizacion en la generacion
        # de la siguiente Jugada.
        def prox(m)
            super(m)
            @movimientos.sample(1, random: @rng)[0].clone
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
            "#{super()} Sesgada con movimientos=#{@movimientos} y rng=#{@rng}"
        end

        # Generar Proxima Jugada. Donde se recibe una Jugada para su posible utilizacion en la generacion
        # de la siguiente Jugada.
        def prox(m)
            super(m)
            prob = @rng.rand(1.0)
            movimientos.keys.each { |k|
                return k.clone if prob <= movimientos[k]
                prob -= movimientos[k]
            }
        end

        # Lleva la estrategia a su estado inicial de rng
        def reset()
            @rng = Random.new(SEED)
        end
    end

    # Clase Estrategia Copiar
    class Copiar < Estrategia

        # Movimiento inicial
        attr_reader :mov_inicial
        # Movimiento inicial
        attr_reader :mov_anterior

        # Constructor de Estrategia Copiar. Recibe un Movimiento valido para iniciar
        def initialize(movimiento)

            if movimiento.class != Symbol
                @inicial = movimiento.clone
            else
                @inicial = Jugadas.symbol_to_jugada(movimiento)
            end

            if !(@inicial.class <= Jugadas::Jugada)
                raise RuntimeError , "Error de Movimiento Inicial, \"#{movimiento.to_s}\" no es una Jugada Valida" 
            end
            if @inicial.class == Jugadas::Jugada
                raise RuntimeError , "Error de Movimiento Inicial, \"#{movimiento.to_s}\" no es una Jugada suficientemente instanciada" 
            end

            reset()
        end

        # Representacion string de una Estrategia Copiar
        def to_s()
            "#{super()} Copiar con mov_inicial=#{@mov_inicial} y mov_anterior=#{@mov_anterior}"
        end

        # Generar Proxima Jugada. Donde se recibe la Jugada pasada del oponente 
        # para su utilizacion en la generacion de la siguiente Jugada.
        def prox(m)
            super(m)
            if m != nil
                @mov_anterior = m.clone
            else
                reset()
            end
            return @mov_anterior.clone
        end

        # Lleva la Estrategia Copiar a su estado inicial
        def reset()
            @mov_anterior = @inicial.clone
        end
    end

    # Clase Estrategia Pensar
    class Pensar < Estrategia

        # Cantidad de Piedras vistas
        attr_reader :r

        # Cantidad de Papel vistas
        attr_reader :p

        # Cantidad de Tijeras vistas
        attr_reader :t

        # Cantidad de Lagartos vistas
        attr_reader :l

        # Cantidad de Spocks vistas
        attr_reader :s

        # Cantidad de Jugadas vistas
        attr_reader :acc

        # Constructor de Estrategia Pensar
        def initialize
            reset()
        end

        # Representacion string de una Estrategia Pensar
        def to_s()
            "#{super()} Pensar con r=#{@r}, p=#{@p}, t=#{@t}, l=#{@l}, s=#{@s}, acc=#{@acc} y rng=#{@rng}"
        end

        # Generar Proxima Jugada. Donde se recibe una Jugada para su posible utilizacion en la generacion
        # de la siguiente Jugada.
        def prox(m)
            super(m)

            analizar(m)

            prob = @rng.rand(@acc)

            if prob < @r
                return Jugadas::Piedra.new
            end
            
            prob -= @r

            if prob < @p
                return Jugadas::Papel.new
            end

            prob -= @p

            if prob < @t
                return Jugadas::Tijera.new
            end

            prob -= @t

            if prob < @l
                return Jugadas::Lagarto.new
            end
            
            return Jugadas::Spock.new
        end

        # Lleva la estrategia a su estado inicial de rng y de vistas
        def reset()
            @rng = Random.new(SEED)
            @r = 1
            @p = 1
            @t = 1
            @l = 1
            @s = 1
            @acc = @r + @p + @t + @l + @s
        end

        def analizar(j)
            case j
                when Jugadas::Piedra
                    @r += 1
                    @acc += 1
                when Jugadas::Papel
                    @p += 1
                    @acc += 1
                when Jugadas::Tijera
                    @t += 1
                    @acc += 1
                when Jugadas::Lagarto
                    @l += 1
                    @acc += 1
                when Jugadas::Spock
                    @s += 1
                    @acc += 1
            end
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

        puts ""

        arg = nil
        begin
            c = Copiar.new(arg)
            puts "Estrategia Copiar No Funciona con: #{arg}"
            return false
        rescue => exception
            puts exception
            puts "Estrategia Copiar Funciona con: #{arg}"
        end

        puts ""

        arg = :a
        begin
            c = Copiar.new(arg)
            puts "Estrategia Copiar No Funciona con: #{arg}"
            return false
        rescue => exception
            puts exception
            puts "Estrategia Copiar Funciona con: #{arg}"
        end
        
        puts ""

        arg = "wat"
        begin
            c = Copiar.new(arg)
            puts "Estrategia Copiar No Funciona con: #{arg}"
            return false
        rescue => exception
            puts exception
            puts "Estrategia Copiar Funciona con: #{arg}"
        end

        puts ""

        arg = :Piedra
        begin
            c = Copiar.new(arg)
            r = c.prox(nil)
            if !(r.class == Jugadas::Piedra)
                raise RuntimeError, "Prox no devolvio una Jugada Piedra, sino #{r}"
            end
            puts "Estrategia Copiar Funciona con: #{arg}"
            other = Jugadas::Spock.new
            r = c.prox(other)
            if !(r.class == other.class)
                raise RuntimeError, "Prox no devolvio un Jugada Spock, sino #{r}"
            end
            puts "Estrategia Copiar Funciona con Prox de: #{r}"
        rescue => exception
            puts exception
            puts "Estrategia Copiar No Funciona con: #{arg}"
            return false
        end

        puts ""

        begin
            p = Pensar.new
            p.prox(nil)
            puts "Estrategia Pensar Funciona con: nil"
        rescue => exception
            puts exception
            puts "Estrategia Pensar No Funciona con: nil"
        end
        
        return true
    end

end