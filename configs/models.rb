require_relative 'database'

class Usuario < Sequel::Model(DB[:usuarios])
end

class UsuarioLogueado < Sequel::Model(DB[:vw_usuarios_logeados])
end

'''
class Level < Sequel::Model(DB[:levels])
end

class Exercise < Sequel::Model(DB[:exercises])
end

class BodyPart < Sequel::Model(DB[:body_parts])
end
'''