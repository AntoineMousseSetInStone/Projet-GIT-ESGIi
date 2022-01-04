pragma solidity >=0.7.0 <0.8.5;
//SPDX-License-Identifier: UNLICENSED

import "./zombiefeeding.sol";

contract ZombieHelper is ZombieFeeding {

    uint levelUpFee = 0.001 ether;

    /*
    Goal : Restreindre l'aptitude d'un zombie en fonction de son level

    @Params 
	    - parma 1 : uint : level a verifier 
	    - param 2 : uint : zombie a verifier 
    @Returns 
	    - out :  bool : true si le level du zombie est >= au param level sinon false 
    */
    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;
    }

     function withdraw() external onlyOwner {
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }

    /*
    Goal : Change fee price
    Steps : 
	    - Step 0 : Set new price
    @Params 
	    - parma 1 : uint : new price
    */
    function setLevelUpFee(uint _fee) external onlyOwner {
        levelUpFee = _fee;
    }

    /*
    Goal : Augmenter level zombie contre de l'ether
    Steps : 
	    - Step 0 : verification du montant d'ethers envoyé par l'utilisateur puis augmentation du level
    @Params 
	    - parma 1 : uint : id du zombie
    */
    function levelUp(uint _zombieId) external payable {
        require(msg.value == levelUpFee);
        zombies[_zombieId].level++;
    }

    /*
    Goal : Changer le nom du zombie a partir du niveau 2
    Steps : 
	    - Step 0 : verification du level et du propriétaire
        - Step 1 : modification du name
    @Params 
	    - parma 1 : uint : id du zombie
	    - param 2 : string : nouveau nom
    */
    function changeName(uint _zombieId, string memory _newName) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        zombies[_zombieId].name = _newName;
    }

    /*
    Goal : Changer l'Adn du zombie a partir du niveau 20
    Steps : 
	    - Step 0 : verification du level et du propriétaire
        - Step 1 : modification du Dna
    @Params 
	    - parma 1 : uint : id du zombie
	    - param 2 : string : nouveau Dna
    */
    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        zombies[_zombieId].dna = _newDna;
    }

    /*
    Goal : Connaitre le nombre de zombie d'un utilisateur
    Steps : 
	    - Step 0 : initialisation tableau (uint) et compteur
        - Step 1 : ajout dans le tableau si l'adress correspond au "owner" du zombie
    @Params 
	    - parma 1 : adress: adresse de l'utilisateur
    @Returns
        - out : uint[]
    */
    function getZombiesByOwner(address _owner) external view returns(uint[] memory){
    uint[] memory result = new uint[](ownerZombieCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < zombies.length; i++) {
      if (zombieToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
    }
}