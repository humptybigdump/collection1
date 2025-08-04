package model.buildings;
//#if(axe)
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
		//#if(scrap)
//@		return Arrays.asList(ECard.SCRAP, ECard.SCRAP, ECard.SCRAP);
		//#else
		return Arrays.asList(ECard.METAL, ECard.METAL, ECard.METAL);
		//#endif
	}
	
	@Override
	public void onBuild(Player p) {
		// grant 1d8
	}

}
//#endif
