// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract Votacion {

    struct Votante {
        bool haVotado;  // si el votante ha votado es true
        uint voto;   // numero de la opcion que ha votado
        uint peso; // peso que tiene en la votación, 1 puede votar y 0 es que no puede votar
    }

    struct Opcion {
        string nombre;   // nombre de la opcion
        uint numeroVotos; // numero de votos
    }

    address public creador; // creador del contrato

    mapping(address => Votante) public votantes; //votantes

    Opcion[] public opciones; //opciones

    bool haTerminado; //true si ha terminado

    string private  ganador; //nombre de la opcion ganadora
    uint private votosGanador; //numero votos de la opcion ganadora

    // Para funciones que solo puede usar el creador
    modifier esCreador(){
        require(msg.sender == creador, "Solo el creador puede utilizar esta funcion de la votacion");
        _;
    }

    // Para el constructor se establece el creador y el atributo haTerminado en false.
    // El creador de primeras puede votar
    // Para crearlo se le introduce un array con las opciones
    constructor(string[] memory nombreOpciones) {
        haTerminado = false;
        creador = msg.sender;
        votantes[creador].peso = 1;
        for (uint i = 0; i < nombreOpciones.length; i++) {
            opciones.push(Opcion({
                nombre: nombreOpciones[i],
                numeroVotos: 0
            }));
        }
    }
    // Función que agrega votantes a traves de un array de direcciones
    // Si ya ha votado no te deja agregarlo
    // Asigna peso 1 a los que se añadan para que puedan votar
    function agregarVotantes(address[] memory _votantes) external esCreador() {
        for(uint i = 0; i<_votantes.length ;i++){
            address votante = _votantes[i];
            require(
                !votantes[votante].haVotado,
                "El votante que desea agregar ya ha votado"
            );
            require(votantes[votante].peso == 0);
            votantes[votante].peso = 1;
        }
            
    }
    // Si tiene peso 0, la votacion ha terminado o ya ha votado, no puede votar
    // Para el votante se agrega haVotado=true y su voto
    // Para la opcion se le añade 1 voto
   function votar(uint opcion) external {
        Votante storage sender = votantes[msg.sender];
        require(sender.peso != 0, "No tienes derecho a votar");
        require(!haTerminado, "La votacion ha terminado");
        require(!sender.haVotado, "Ya has votado");
        sender.haVotado = true;
        sender.voto = opcion;

        opciones[opcion].numeroVotos += sender.peso;
    }
    //Establece haTerminado=true, realiza el recuento de votos y guarda los resultados
    function terminaVotacion() external esCreador() {
        haTerminado = true;
        uint numeroVotosGanador = 0;
        string memory opcionGanadora;
        for (uint o = 0; o < opciones.length; o++) {
            if (opciones[o].numeroVotos > numeroVotosGanador) {
                numeroVotosGanador = opciones[o].numeroVotos;
                opcionGanadora = opciones[o].nombre;
            }
        }
        ganador = opcionGanadora;
        votosGanador = numeroVotosGanador;
    }
    //Muestra los resultados
    //Si no ha finalizado te salta una advertencia
    function verResultado() external view returns(string memory opcionGanadora, uint numeroVotosGanador){
        require(haTerminado, "No se puede ver los resultados antes de finalizar");
        opcionGanadora = ganador;
        numeroVotosGanador = votosGanador;
        
    }
    
}