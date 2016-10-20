var go= require("go");

var roleBuilder = {

    /** @param {Creep} creep **/
    run: function(creep) {

//TODO: make this goal stateful (expensive find all by path, and could end up walking back and fourth as various stuff decays) - maybe even put a flag on the goal
//TODO: make repairing play better with towers and urgency

	    if(creep.memory.building && creep.carry.energy == 0) {
            creep.memory.building = false;
            creep.say('harvesting');
	    }
	    if(!creep.memory.building && creep.carry.energy == creep.carryCapacity) {
	        creep.memory.building = true;
	        creep.say('building');
	    }

	    if(creep.memory.building) {
	        var target = creep.pos.findClosestByPath(FIND_CONSTRUCTION_SITES);
            if(target) {
                if(creep.build(target) == ERR_NOT_IN_RANGE) {
                    var result = creep.moveTo(target);
                    if (result && result !=ERR_TIRED) creep.say("move failed:" + result);
                }
            } else {
                var towerBackoff=500;
                var maxWall=1000+towerBackoff;
                var maxRoad=1000+towerBackoff;//let walkers heal it, but get them before they decay (swamp roads lose 500, so this is only 2 ticks)
                var maxRampart=1500+towerBackoff;
                var maxMisc=1000+towerBackoff;
                var maxCont=1000+towerBackoff;
    
                var carrierLoad=400;
                if (creep.room.energyAvailable>=creep.room.energyCapacityAvailable-carrierLoad) {
                    towerBackoff=1500;
                    
                    maxWall=10000+towerBackoff;
                    maxRoad=3000+towerBackoff;
                    maxRampart=15000+towerBackoff;
                    maxMisc=10000+towerBackoff;
                    maxCont=5000+towerBackoff;
                }


                var closestDamagedStructure = creep.pos.findClosestByRange(FIND_STRUCTURES, {
                    filter: (structure) =>  { 
                        if ( structure.hits > structure.hitsMax-100) return false;
                        switch (structure.structureType){
                            case STRUCTURE_WALL: return structure.hits<maxWall;
                            case STRUCTURE_ROAD: return structure.hits<maxRoad;
                            case STRUCTURE_RAMPART: return structure.hits<maxRampart;
                            case STRUCTURE_CONTAINER: return structure.hits<maxCont;
                            default: return structure.hits<maxMisc;
                        }
                }});
                
                if(closestDamagedStructure) {
                    if (creep.pos.isNearTo(closestDamagedStructure)) {
                        var result = creep.repair(closestDamagedStructure);
                        console.log("builder repairing:" + closestDamagedStructure + "; result:" + result);
                        Memory.stats.builderRepairs++;
                        return;
                    } else {
                        var result = creep.moveTo(closestDamagedStructure);
                        if (result != OK && result != ERR_TIRED) console.log("error moving to repair:" + result);
                        return;
                    }
                }


                //nothing to do - just get out of the way
                if (Game.time % 10 ==0)
                {
                    creep.say("2->upgrader");
                    creep.memory.tempRole="upgrader";
                    creep.memory.tempRoleUntil=Game.time+50;
                }
            }
	    }
	    else {
            if (!go.collect(creep) && go.harvest(creep))
            {
                creep.say("get failed");
            }
	    }
	}
};

module.exports = roleBuilder;


