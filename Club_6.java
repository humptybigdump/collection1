package model.buildings;
//#if(club)
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
		//#if(scrap)
//@		return Arrays.asList(ECard.SCRAP, ECard.SCRAP, ECard.SCRAP);
		//#else
		return Arrays.asList(ECard.WOOD, ECard.WOOD, ECard.WOOD);
		//#endif
	}

	@Override
	public void onBuild(Player p) {
		// grant 1d6
	}
}
//#endif
