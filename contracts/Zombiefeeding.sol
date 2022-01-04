pragma solidity >=0.7.0 <0.8.5;
//SPDX-License-Identifier: UNLICENSED

import "./zombiefactory.sol";

//Interface CryptoKitt
abstract contract KittyInterface {
  function getKitty(uint256 _id) virtual external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

contract ZombieFeeding is ZombieFactory {

  /*
  Goal : Verification appartenance zombie
  @Params 
    - param 1 : uint : id du zombie a verifier 
  @Returns 
    - out :  bool : true si le zombie lui appartient sinon false 
  */
  modifier onlyOwnerOf( uint _zombieId){
        require(msg.sender == zombieToOwner[_zombieId]);
        _;
    }

  //Déclaration interface kittyContract
  KittyInterface kittyContract;
  // Function pour definier l'address du contrat Kitty
  function setKittyContractAddress(address _address) external onlyOwner {
  kittyContract = KittyInterface(_address);
  }

  // Goal : verifier le temps qu'il reste au coolDown
  function _triggerCooldown(Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(block.timestamp + coolDownTime);
  }

  // Goal : return true si le cooldown est termine (assez de temps ecoulé depuis que le zombie a manger)
  function _isReady(Zombie storage _zombie) internal view returns (bool){
    return (_zombie.readyTime <= block.timestamp);
  }

  /*
  Goal : combinaison du Dna du zombie passe en parametre avec une autre espece 
  In 6 Steps:
      -Step 0 : Verification du propiétaire du zombie
      -Step 1 : Déclaration d'un 'zombie local' myZombie -> pointeur sur zombies[_zombieId]
      -Step 2 : Verification que _targetDna à 16 chiffre
      -Step 3 : Déclaration newDna = (Dna actuelle + _targetDna passé en parametre)/2
      -Step 4 : Verification si le hashage de _species = au hashage de "kitty"
        -si oui => newDna se termine par 99
        -sinon => newDna = step 3
      -Step 5 : Appel de la fonction _createZombie avec en parametre un nom et le nouvel adn
  Result : Nouveau zombie avec nouveau Dna
  Author : Antoine Mousse
  */
  function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal onlyOwnerOf(_zombieId){
    Zombie storage myZombie = zombies[_zombieId];
    require(_isReady(myZombie));
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2;
    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99;
    }
    _createZombie("NoName", newDna);
    _triggerCooldown(myZombie);
  }


   /*
    Goal : Recuperer Dna kitty et créér un nouveau zombie
    In 4 Steps:
        -Step 0 : declaration kittyDna
        -Step 1 : Récuperation du kittyDna avec l'appel de la fonction getKitty et du parametre _kittyId
        -Step 2 : Création d'un noveau zombie avec l'appel de la fonction feedAndMutiply
    Result : Nouveau zombie ayant manger un 'kitty'
    Author : Antoine Mousse
    */
  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }

}