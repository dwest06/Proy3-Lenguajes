# Manejador de Jugadas    
module Jugadas

    # Clase Jugada, Controla las posibles jugadas del juego
    class Jugada

        # Representacion string de una Jugada
        # 
        # @return String de una Jugada
        def to_s()
            "Jugada"
        end

        # Manejador de puntos al Ejecutar una Jugada contra otra Jugada. 
        # Revisa si es una Jugada suficientemente instancia antes de dar el puntaje, si no es levanta excepcion
        # 
        # @param Jugada j : Jugada a la cual comparar para calcular los puntos entre dos jugadas.
        # 
        # @return [Int] : arreglo de dos posiciones representando el puntaje
        def puntos(j)
            if !(j.class <= Jugada)
                raise ArgumentError, "Error \"#{j.to_s}\" no es una Jugada Valida" 
            end
            if j.class == Jugada
                raise ArgumentError, "Error \"#{j.to_s}\" no es una Jugada suficientemente instanciada" 
            end
            [-1,-1]
        end
    end

    # Clase de la Jugada Piedra
    class Piedra < Jugada

        # Representacion string de una Jugada Piedra
        # 
        # @return String de una Jugada Piedra
        def to_s()
            "#{super()} Piedra"
        end

        # Manejador de puntos al Ejecutar una Jugada de Piedra contra otra Jugada
        # 
        # @param Jugada j : Jugada a la cual comparar para calcular los puntos entre dos jugadas.
        # 
        # @return [Int] : arreglo de dos posiciones representando el puntaje
        def puntos(j)
            super(j)

            case j
                when Piedra
                    [0,0]
                when Lagarto
                    [1,0]
                when Tijera
                    [1,0]
                when Spock
                    [0,1]
                when Papel
                    [0,1]
            end
        end
    end

    # Clase de la Jugada Papel
    class Papel < Jugada

        # Representacion string de una Jugada Papel
        # 
        # @return String de una Jugada Papel
        def to_s()
            "#{super()} Papel"
        end

        # Manejador de puntos al Ejecutar una Jugada de Papel contra otra Jugada
        # 
        # @param Jugada j : Jugada a la cual comparar para calcular los puntos entre dos jugadas.
        # 
        # @return [Int] : arreglo de dos posiciones representando el puntaje
        def puntos(j)
            super(j)
            case j
                when Piedra
                    [1,0]
                when Lagarto
                    [0,1]
                when Tijera
                    [0,1]
                when Spock
                    [1,0]
                when Papel
                    [0,0]
            end
        end
    end

    # Clase de la Jugada Tijera
    class Tijera < Jugada

        # Representacion string de una Jugada Tijera
        # 
        # @return String de una Jugada Tijera
        def to_s()
            "#{super()} Tijera"
        end

        # Manejador de puntos al Ejecutar una Jugada de Tijera contra otra Jugada
        # 
        # @param Jugada j : Jugada a la cual comparar para calcular los puntos entre dos jugadas.
        # 
        # @return [Int] : arreglo de dos posiciones representando el puntaje
        def puntos(j)
            super(j)
            case j
                when Piedra
                    [0,1]
                when Lagarto
                    [1,0]
                when Tijera
                    [0,0]
                when Spock
                    [0,1]
                when Papel
                    [1,0]
            end
        end
    end

    # Clase de la Jugada Lagarto
    class Lagarto < Jugada

        # Representacion string de una Jugada Lagarto
        # 
        # @return String de una Jugada Lagarto
        def to_s()
            "#{super()} Lagarto"
        end

        # Manejador de puntos al Ejecutar una Jugada de Lagarto contra otra Jugada
        # 
        # @param Jugada j : Jugada a la cual comparar para calcular los puntos entre dos jugadas.
        # 
        # @return [Int] : arreglo de dos posiciones representando el puntaje
        def puntos(j)
            super(j)
            case j
                when Piedra
                    [0,1]
                when Lagarto
                    [0,0]
                when Tijera
                    [0,1]
                when Spock
                    [1,0]
                when Papel
                    [1,0]
            end
        end
    end

    # Clase de la Jugada Spock
    class Spock < Jugada

        # Representacion string de una Jugada Spock
        # 
        # @return String de una Jugada Spock
        def to_s()
            "#{super()} Spock"
        end

        # Manejador de puntos al Ejecutar una Jugada de Spock contra otra Jugada
        # 
        # @param Jugada j : Jugada a la cual comparar para calcular los puntos entre dos jugadas.
        # 
        # @return [Int] : arreglo de dos posiciones representando el puntaje
        def puntos(j)
            super(j)
            case j
                when Piedra
                    [1,0]
                when Lagarto
                    [0,1]
                when Tijera
                    [1,0]
                when Spock
                    [0,0]
                when Papel
                    [0,1]
            end
        end
    end

    # Retorna la Jugada asociada al simbolo. Retorna nil si no hay una Jugada asociada
    # 
    # @param Symbol s : Simbolo a convertir a una Jugada
    # 
    # @return [Jugada,nil] : Jugada obtenida del Simbolo, nil en caso de no ser un simbolo valido
    def Jugadas.symbol_to_jugada(s)
        case s
            when :Piedra
                return Piedra.new
            when :Papel
                return Papel.new
            when :Tijera
                return Tijera.new
            when :Lagarto
                return Lagarto.new
            when :Spock
                return Spock.new
        end
        return nil
    end

    # Convierte un string en una jugada, si es valido
    # 
    # @param Symbol s : Simbolo a convertir a una Jugada
    # 
    # @return Jugada : Jugada obtenida del Simbolo, nil en caso de no ser un simbolo valido
    def Jugadas.to_jugada(s) 
        if ! s.kind_of?(String)
            raise ArgumentError, "Jugadas.to_jugada requiere un string como argumento"
        end

        s.downcase!
        case s
            when "piedra"
                return Piedra.new
            when "papel"
                return Papel.new
            when "tijera"
                return Tijera.new
            when "lagarto"
                return Lagarto.new
            when "spock"
                return Spock.new
        end
        return nil
    end

    # Pruebas de Jugadas
    # 
    # @return Bool : true si pasa todas las pruebas, false en caso contrarior
    def Jugadas.test_jugadas()
        ju = Jugada.new
        arr = [Piedra.new, Papel.new, Tijera.new, Lagarto.new, Spock.new]

        begin
            ju.puntos(ju)
            puts "#{ju} Funciona Incorrectamente con #{ju}"
            return false
        rescue => exception
            puts exception
            puts "#{ju} Funciona Correctamente con #{ju}"
        end

        arr.each do |j1|
            begin
                j1.puntos(ju)
                puts "#{ju} Funciona Incorrectamente con #{j1}"
                return false
            rescue => exception
                puts exception
                puts "#{ju} Funciona Correctamente con #{j1}"
            end

            puts "\nIniciando Pruebas de Puntos con Jugadas:\n"

            arr.each do |j2|
                begin
                    res = j1.puntos(j2)
                    if res == j2.puntos(j1).reverse
                        
                        puts "#{j1} Funciona Correctamente con #{j2}, dando: #{res}"
                    else
                        puts "#{j1} Funciona Incorrectamente con #{j2}"
                        return false
                    end
                rescue => exception
                    puts exception
                    puts "#{j1} Funciona Incorrectamente con #{j2}"
                    return false
                end
            end
            puts ""
        end
        return true
    end
end


