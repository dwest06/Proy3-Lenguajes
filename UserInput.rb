# Manejador de Input de Usuario    
module UserInput

    # Modulo de Jugadas
    require './Jugadas.rb'

    # Devuelve lambda que puede obtener una Jugada de usuario por consola
    #
    # @return Proc : Lambda que maneja obtener input de usuario por consola y lo convierte a una Jugada
    def UserInput.from_console()
        return lambda {
            prompt = "> "
            puts "Las Jugadas Validas son: Piedra, Papel, Tijera, Lagarto, Spock"
            print prompt
            while user_input = gets.chomp # loop while getting user input
                res = Jugadas.to_jugada(user_input)
                if res == nil
                    puts "\"#{user_input}\" no es una jugada valida"
                    puts "Las Jugadas Validas son: Piedra, Papel, Tijera, Lagarto, Spock"
                    print prompt
                else
                    return res
                end
            end
        }
    end

end