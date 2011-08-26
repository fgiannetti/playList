require "rubygems"
require "bundler/setup"

require 'sinatra'
require 'haml'
require 'logger'

#Para incluir el directorio lib
$: << File.join(File.dirname(__FILE__), 'lib')
require 'playlist'
require 'playlisterror'

#parches para ruby 1.9.2
enable :run
set :views, File.dirname(__FILE__) + "/views"
set :public, File.dirname(__FILE__) + "/public"

get '/' do
	to_index
end

post '/add' do
	playlist=Playlist.instance
	playlist.encolar(params[:tema],params[:artista],env['REMOTE_ADDR']) if validar(params[:tema],env['REMOTE_ADDR'],playlist)
	to_index
end

post '/discos' do
	@options=Playlist.instance.discos(params[:artista])
	haml :'partials/optionsSelect'
end

post '/temas' do
	@options=Playlist.instance.temas(params[:artista],params[:disco])
	haml :'partials/optionsSelect'
end

get '/lista' do
	@cola=Playlist.instance.cola
	haml :'partials/cola'
end

post '/remove' do
	Playlist.instance.remove(params[:tema],params[:artista],env['REMOTE_ADDR'])
	redirect '/lista'
end

configure do
	LOG=Logger.new('log/app.log')
	LOG.level=Logger::ERROR
end

  
helpers do
 
	#Hace las validaciones sobre el tema elegido
	def validar(tema,ip,playlist)
		@errors=nil
  	  	@errors= PlaylistError::MESSAGES[:existeenlista] if playlist.include? tema
  	  	@errors= PlaylistError::MESSAGES[:superamaxip] if playlist.supera_max_ip? ip
		@errors.nil?
  	end

	#Prepara las variables para la pagina y la muestra
	def to_index
		begin
			playlist=Playlist.instance
			@artistas=playlist.artistas
			@artistaSel=params['artista']
			@discoSel=params['disco']
			haml :index
		rescue Exception => ex
		        LOG.error("ERROR: #{ex}\n"){ 
				ex.backtrace.join("\n")
			}

			show_error('error.jpg','Auch! Hubo un error!')
		end
	end

	def show_error(imagen,mensaje=nil)
		@img="/images/#{imagen}"
	        @msg=mensaje
	        haml :error
	end
end

not_found do
	show_error('error-404.png')
	haml :error
end
