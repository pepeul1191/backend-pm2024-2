require 'json'

post '/usuario/validar' do
  # params (json)
  status = 500
  resp = ''
  request.body.rewind
  body = request.body.read
  data = JSON.parse(body) 
  usuario = data['usuario']
  contrasenia = data['contrasenia']
  # db access
  begin
    # SELECT id, member_id FROM usuarios
    # WHERE usuario = '#{usuario}' AND contrasenia = '#{contrasenia}';
    record = Usuario.where(usuario: usuario, contrasenia: contrasenia).select(:id).first
    # result set
    usuario_id = nil
    member_id = nil
    data = ''
    message = ''
    if record then
      resp = UsuarioLogueado.where(usuario_id: record.id).first.to_json
      status = 200
    else
      status = 404
      resp = 'Usuario y/o contraseña no válidos'
    end
  rescue Sequel::DatabaseError => e
    resp = 'Error al acceder a la base de datos'
    puts e.message
  rescue StandardError => e
    resp = 'Ocurrió un error no esperado al validar el usuario'
    puts e.message
  end
  # response
  status status
  resp
end

post '/usuario/cambiar-contrasenia' do
  # params
  status = 500
  resp = ''
  correo = params[:correo]
  # db access
  begin
    chars = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten
    new_password = (0...3).map { chars[rand(chars.length)] }.join
    query = <<-STRING
      UPDATE usuarios SET contrasenia = '#{new_password}' WHERE id = (
        SELECT usuario_id FROM vw_usuarios_logeados 
        WHERE correo = '#{correo}'
      );
    STRING
    puts query
    records = DB[query].update
    puts records
    if records > 0 then
      resp = 'Contraseña actualizada'
      status = 200
    else
      status = 404
      resp = 'Correo no registrado'
    end
  rescue Sequel::DatabaseError => e
    # resp[:message] = 'Error al acceder a la base de datos'
    # resp[:data] = e.message
    resp = e.message
  rescue StandardError => e
    # resp[:message] = 'Error al acceder a la base de datos'
    # resp[:data] = e.message
    resp = e.message
  end
  # response
  status status
  resp
end
