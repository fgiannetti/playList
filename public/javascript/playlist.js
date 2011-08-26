//hace el pedido para armar la lista de temas encolados
function updateLista(){
	$('#lista').load('/lista');
}

function checkForm(){
	if($('#temas').val()=='')
		alert('La idea es seleccionar un tema');
}

//acciones al cambiar el artista
function changeArtista(){
	var value=$("#artistas").val();
	$('#discos').load('/discos',{artista:value});
	$('#temas').load('/temas',{artista:value,disco:''});
}

//acciones al cambiar el disco
function changeDisco(){
	var value=$("#discos").val();
	$('#temas').load('/temas',{artista:$("#artistas").val(),disco:value});
}

function removeTema(nombre,artista){
	$('#lista').load('/remove',{'tema':nombre,'artista':artista});
}
