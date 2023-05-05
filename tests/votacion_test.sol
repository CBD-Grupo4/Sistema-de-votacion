// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol";
import "hardhat/console.sol";
import "contracts/Votacion.sol";

contract votacionTest {

    string[] opciones = ["a","b"];

    Votacion votacion;
    function inicializacion () private {
        votacion = new Votacion(opciones);
    }

    function compruebaAgregarVotantes () public {
        console.log("Comprobando la adicion de votantes");
	//creamos una nueva direccion de usuario para agregarlo
        inicializacion();
        address[] memory direccion = new address[](1);
        direccion[0] = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
	//agregamos el nuevo votante a la votacion y comprobamos que el peso sea 1, es decir, puede votar
        votacion.agregarVotantes(direccion);
        (,,uint peso) = votacion.votantes(0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C);
        Assert.equal(peso, 1, "el peso deberia ser 1 (puede votar)");
    }

    function compruebarVotar () public {
        console.log("Comprobando el proceso de votacion");
        inicializacion();
        (,uint numeroVotos1) = votacion.opciones(0);
        votacion.votar(0);
        (,uint numeroVotos2) = votacion.opciones(0);
        (bool haVotado,,) = votacion.votantes(msg.sender);
	//se comrpueba que el numero de votos de la opcion sea el indicado
        Assert.equal(numeroVotos1+1, numeroVotos2, "el numero de votos de la opcion elegida tras votar deberia ser el de antes de votar + 1");
	//se comprueba que el votante ha votado
        Assert.equal(haVotado, true, "el atributo haVotado del votante deberia devolver true");
    }

    function compruebaOpcionMasVotada () public {
        console.log("Comprobando la opcion ganadora");
	//se vota la primera opcion
        inicializacion();
        votacion.votar(0);
        votacion.terminaVotacion();
        string memory opcionGanadora;
        uint numeroVotosGanador;
        (opcionGanadora,numeroVotosGanador) = votacion.verResultado();
	//se cierra la votacion y se comprueba que el numero de votos de la opcion ganadora es 1 y que la opcion ganadora es la primera, es decir, la opcion A
        Assert.equal(numeroVotosGanador, uint(1), "el numero e votos de la opcion ganadora deberia ser 1");
        Assert.equal(opcionGanadora, string("A"), "la opcion ganadora deberia ser la A (la primera)");
    }
    function compruebaNoPuedeVotar () public {
        console.log("Comprobando que un ususario no agregado a la votacion no tiene permitido votar");
        inicializacion();
        address[] memory direccion = new address[](1);
        direccion[0] = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
        (,,uint peso) = votacion.votantes(0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C);
	//se comprueba que una direccion no agregada tiene de peso 0, es decir, no puede votar
        Assert.equal(peso, 0, "el peso debe ser 0 porque no puede votar");
    }
    
}