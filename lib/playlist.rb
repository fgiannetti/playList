require 'singleton'
require 'yaml'
require 'recur'
require 'playitem'

class Playlist
	include Singleton
	CONF='conf/appconfig.yml'
	
	attr_reader :mainrepo, :filelist, :cola
	
	def initialize
		$conf=read_conf
		initfiles
		@cola=Array.new
	end
	
	#Asumo que el archivo existe y es valido
	def encolar(file,artista,ip)
		@cola << PlayItemCola.new(file,artista,ip)
		#Si es el primer tema empiezo a reproducir
		play if @cola.size==1
		@cola.size
	end
	
	#boolean que indica si se supera el maximo para esa ip
	def supera_max_ip?(ip)
		$conf[:max_by_ip]>-1 && count_by_ip(ip)>=$conf[:max_by_ip]
	end
	
	def artistas
		@estructura.artistas
	end
	
	def discos(artista)
		artista.empty?? Array.new : @estructura.discos(artista)
	end
	
	def temas(artista,disco)
		disco.empty?? Array.new : @estructura.temas(artista,disco)
	end
	
	def include?(tema)
		@cola.map{|item|
			item.path
		}.include?tema
	end

	#Borra el tema de la lista buscando por nombre del tema, artista
	#y solo borra si se esta borrando desde la ip que lo dio de alta
	def remove(tema,artista,ip)
		@cola.delete_if{|item|
			item.nombre==tema && artista==item.artista && item.ip==ip
		}
	end
		
	private
	
	#Lee el archivo de configuracion
	def read_conf
		raise "conf file not found" unless File.exists?(CONF)
  		YAML::load(IO.readlines(CONF).join)
	end
	
	#Inicializa la lista de archivos en el repositorio
	#TODO: conviene que arme la lista cada vez que carga la pagina para poder agregar archivos sin reiniciar?
	def initfiles
		Dir.mkdir($conf[:mainrepo]) unless File.exists?($conf[:mainrepo])
		@estructura=Recurse.new($conf[:mainrepo])
		@estructura.build
	end
	
	#La cantidad de temas en la cola para una ip
	def count_by_ip(ip)
		@cola.select{|tema|
			tema.ip==ip
		}.length
	end
	
	#Reproduce la lista
	def play
		puts "PLAY"
                Thread.new{
                        while(!@cola.empty?)
                        	system("#{$conf[:command]} \"#{@cola.at(0).path}\"")
                                @cola.delete_at(0)
                                #Espero 2 segundos entre temas
                                sleep 2
				@cola<<random if (@cola.empty? && $conf[:enable_random])
			end
                }
        end
	
	#FIXME: hay algo mas lindo?
	def random
		artista=@estructura.artistas[rand(@estructura.artistas.size)]
		disco=@estructura.discos(artista)[rand(@estructura.discos(artista).size)]
		tema=@estructura.temas(artista,disco)[rand(@estructura.temas(artista,disco).size)].path
		PlayItemCola.new(tema,artista,nil)
	end
        
end
