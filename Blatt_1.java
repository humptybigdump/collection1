import greenfoot.Actor;
import greenfoot.World;
import java.util.List;

/**Blaetter in der KARA-Welt
 * Ver 0.21;  thh; 30.6.08  */
 
public class Blatt extends Actor {

    public Blatt() {
    }

/** wird aufgerufen, wenn das Blatt in die Wiese platziert wird */
    protected void addedToWorld(World world) {
        // Wenn auf der Kachel schon eine Mauer oder ein Blatt ist, 
        // wird das Blatt wieder entfernt
        if (getWorld().getObjectsAt(getX(), getY(), Baum.class).size() > 0 ||
            getWorld().getObjectsAt(getX(), getY(), Blatt.class).size() > 1) {
              getWorld().removeObject(this);
              return;
        }
        // scheinbar wird das abzulegend Blatt schon in der Liste der Blaetter 
        // mitgezaehlt. Daher hier >1 statt >0 !!
    }

/** setLocation überschreiben, um ein Blatt nicht auf einen Baum oder 
 *  anderes Blatt ziehen zu können! */ 
    public void setLocation(int x, int y)   {
         List baum = getWorld().getObjectsAt(x, y, Baum.class);
         List blatt = getWorld().getObjectsAt(x, y, Blatt.class);
         if (baum.isEmpty() && blatt.isEmpty()) {
             super.setLocation(x,y);
         }
     }
      
}