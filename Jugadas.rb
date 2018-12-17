=begin
    Manejador de Jugadas    
=end
module Jugadas
    # Clase Jugada, Controla las posibles jugadas del juego
    class Jugada

        # Representacion string de una Jugada
        def to_s()
            "Jugada"
        end

        # Manejador de puntos al Ejecutar una Jugada contra otra Jugada
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

        # Representacion string de una Jugada
        def to_s()
            "#{super()} Piedra"
        end

        # Manejador de puntos al Ejecutar una Jugada de Piedra contra otra Jugada
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

        # Representacion string de una Jugada
        def to_s()
            "#{super()} Papel"
        end

        # Manejador de puntos al Ejecutar una Jugada de Papel contra otra Jugada
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

        # Representacion string de una Jugada
        def to_s()
            "#{super()} Tijera"
        end

        # Manejador de puntos al Ejecutar una Jugada de Tijera contra otra Jugada
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

        # Representacion string de una Jugada
        def to_s()
            "#{super()} Lagarto"
        end

        # Manejador de puntos al Ejecutar una Jugada de Lagarto contra otra Jugada
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

        # Representacion string de una Jugada
        def to_s()
            "#{super()} Spock"
        end

        # Manejador de puntos al Ejecutar una Jugada de Spock contra otra Jugada
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

    def test_jugadas()
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


