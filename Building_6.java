package model.buildings; 

import java.util.List; 
import java.util.Set; 

import model.ECard; 
import model.Player; 

public abstract  class  Building {
	
	private final EBuilding buildingType;

	

	public Building(EBuilding buildingType) {
		this.buildingType = buildingType;
	}

	

	public final EBuilding getType() {
		return buildingType;
	}

	

	public boolean canBuild(Set<EBuilding> buildings) {
		return true;
	}

	

	public abstract List<ECard> getResourceCosts();

	

	public abstract void onBuild(Player p);


}
