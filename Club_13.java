package model.buildings;

import java.util.Arrays;
import java.util.List;

import model.ECard;
import model.Player;

public class Club extends Building {

	public Club() {
		super(EBuilding.CLUB);
	}

	@Override
	public List<ECard> getResourceCosts() {
		return Arrays.asList(ECard.WOOD, ECard.WOOD, ECard.WOOD);
	}

	@Override
	public void onBuild(Player p) {
		// grant 1d6
	}
}
