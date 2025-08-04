@MessageDriven(name = "Bestellannahme", 
               activationConfig = {
                      @ActivationConfigProperty(
                         propertyName = "destinationType", 
                         propertyValue = "javax.jms.Queue"),
                      @ActivationConfigProperty(
                         propertyName = "destination", 
                         propertyValue = "queue/A") })
public class BestellannahmeImpl implements MessageListener {
  public void onMessage(Message nachricht) {
    try {
      TextMessage txt = (TextMessage) nachricht;
      if (txt.equals("Warp 9, Energie!") {
        System.out.println("Captain Archer, auf die Brücke!");
        . . .
      }
    } catch (JMSException e) {
      throw new EJBException(e);
    }
  }
}
