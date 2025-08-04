package model.buildings;

import java.util.Arrays;
import java.util.List;

import model.ECard;
import model.Player;

public class Axe extends Building {

	public Axe() {
		super(EBuilding.AXE);
	}

	@Override
	public List<ECard> getResourceCosts() {
		return Arrays.asList(ECard.METAL, ECard.METAL, ECard.METAL);
	}
	
	@Override
	public void onBuild(Player p) {
		// grant 1d8
	}

}
