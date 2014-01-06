#Arma un Hash con los directorios y los archivos (2 niveles)
require 'playitem'

class Recurse
	
	def initialize(base)
		@base=base
		@allfiles=Hash.new
	end

	def build
		doDirs(@base){|dirname|
			subdirs=processDir(File.join(@base,dirname))
			@allfiles[dirname]=subdirs unless subdirs.empty?
		}
	end
	
	#Devuelve un Array con todos los elementos del nivel 1
	def artistas
		#TODO: Ver si se puede ordenar el Hash una sola vez
		@allfiles.keys.sort
	end
	
	#Devuelve un Array con los discos de un Artista
	def discos(artista)
		#TODO: Ver si se puede ordenar el Hash una sola vez
		@allfiles[artista].keys.sort
	end
	
	#Devuelve el Array con los temas de un  artista y disco
	def temas(artista,disco)
		@allfiles[artista][disco]
	end

	private
	def processDir(root)
		subdirs=Hash.new
		doDirs(root){|dirname|
			subdirs[dirname]=files(File.join(root,dirname))
		}
		subdirs
	end
	
	#Ejecuta el bloque para cada directorio hijo del root
	def doDirs(root)
		Dir.entries(root).each{|name|
			next if name=~ /^\.+$/
			if File.directory?(File.join(root,name)) && File.readable?(File.join(root,name))
				yield name
			end	
		}
	end

	def files(dirname)
		filesDir=Array.new
		Dir.chdir(dirname) do
			Dir.glob('*.[mM][pP]3'){|fileName|
				filesDir<< PlayItem.new(File.join(dirname,fileName)) if File.file? File.join(dirname,fileName)
			}
		end
		
		filesDir.sort{|a,b|
			a.nombre <=> b.nombre
		}
	end
end
