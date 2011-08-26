#Clase para los temas encolados.
#guarda info que se muestra en la pagina

#TODO: cuando haga la clase para la tabla, incluirla como atributo de la clase
class PlayItem
	
	attr_reader :nombre, :path
	
	def initialize(path)
		@path=path
		@nombre= File.basename(path,".mp3")
	end
end

class PlayItemCola < PlayItem
	attr_reader :ip, :artista
	
	def initialize(path,artista, ip)
		super(path)
		@ip=ip
		@artista= artista
	end
end
