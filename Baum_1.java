import greenfoot.Actor;
import greenfoot.World;

import java.util.List;

/**Baumstumpf in KARAs Welt
 * Ver. 0.14; thh 14.6.08 */
 
public class Baum extends Actor {
	public Baum() {
	}

	protected void addedToWorld(World world) {
		// bereits existierende Aktoren auf der Kachel werden geloescht
		List l = getWorld().getObjectsAt(getX(), getY(), null);
		for (int i = 0; i < l.size(); i++) {
			Actor actor = (Actor) l.get(i);
			if (actor != this) {
				getWorld().removeObject(actor);
			}
		}
	}
	
/** setLocation überschreiben, um einen Baum nicht auf anderen Baum ziehen
 *  zu koennen und alles andere ggfs. zu entfernen. */ 
    public void setLocation(int x, int y)   {
        List l = getWorld().getObjectsAt(x, y, null);
		for (int i = 0; i < l.size(); i++) {
			Actor actor = (Actor) l.get(i);
			if (actor != this) {getWorld().removeObject(actor);}
		}
		super.setLocation(x,y);
    }
}