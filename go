module.exports = {
        collect:function(creep, doRepair){
    	        //collect
                var nearestContainer = creep.pos.findClosestByRange(FIND_STRUCTURES, {
                        filter: (structure) => {
                            return (structure.structureType == STRUCTURE_CONTAINER) && structure.store.energy >0;
                        }
                });
                //console.log("go.collect: nearest=" + nearestContainer);
                if (nearestContainer) {
                    if (doRepair && nearestContainer.hits<nearestContainer.hitsMax) {
                        creep.repair(nearestContainer);
                    } else {
                        if(nearestContainer.transfer(creep, RESOURCE_ENERGY) == ERR_NOT_IN_RANGE) {
                            var result = creep.moveTo(nearestContainer);
                            if (result && result !=ERR_TIRED) creep.say("move failed:" + result);
                        }
                    }
                }
                return nearestContainer;
    },
    harvest: function(creep){
	        var sources = creep.room.find(FIND_SOURCES);
	        var mysource= sources[creep.memory.sourceId||creep.room.defaultSourceId||0];
            if(creep.harvest(mysource) == ERR_NOT_IN_RANGE) {
                var result = creep.moveTo(mysource);
                if (!result) {
                    //success
                } else if (result == ERR_TIRED){
                    //ignore
                } else if (result){
                    creep.say("move failed:" + result);
                    return result;
                }
            }
    }
};