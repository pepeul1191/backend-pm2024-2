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
    puts '1 ++++++++++++++++++++++++++'
    puts record
    puts '2 ++++++++++++++++++++++++++'
    # result set
    usuario_id = nil
    member_id = nil
    data = ''
    message = 'Usuario no encontrado'
    if record then
      resp = UsuarioLogueado.where(usuario_id: record.id).first.to_json
      status = 200
    else
      status = 404
      resp = 'Usuario no encontrado'
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
  dni = params[:dni]
  email = params[:email]
  # db access
  begin
    query = <<-STRING
      SELECT U.id AS user_id FROM members M
      INNER JOIN users U ON M.id = U.member_id
      WHERE M.dni='#{dni}' AND M.email = '#{email}';
    STRING
    record = DB[query].first
    if record then
      chars = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten
      new_password = (0...15).map { chars[rand(chars.length)] }.join
      # UPDATE users SET password='#{new_password}' 
      # WHERE id = #{record[:user_id]};
      User[record[:user_id]].update(password: new_password)
      resp = 'Contraseña actualizada'
      status = 200
    else
      status = 404
      resp = 'Usuario no encontrado'
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
