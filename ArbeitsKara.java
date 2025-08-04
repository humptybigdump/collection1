import greenfoot.*;  // (World, Actor, GreenfootImage, Greenfoot and MouseInfo)

/**
 * Write a description of class ArbeitsKara here.
 * 
 * @author (your name) 
 * @version (a version number or a date)
 */
public class ArbeitsKara  extends Kara{
    
    public ArbeitsKara(){
        setAnzahlBlaetter(40);
    }
    
    
    /**
     * A4 Lauf zum Blatt und weiche Baeumen aus
     */
    public void laufeAllee(){
       
               
    }
   
    
    /**
     * A5 Sammle Blaetter bis zum Baum und melde die Anzahl
     */
    
    public int meldeBaeume(){
        
        return 0;
    }
    
    /**
     * A6 Sammle eine Blattspur, drehe rechts um und leg eine doppelt so lange Spur ab
     */
    public void zumBaumUndWeiter(){
        
        
    }

    
    
    
    /**
     * Hier die Zusatzaufgabe
     */
    public void pilzInDieEcke(){
      
      
            while(!istPilzVorne()){
                if(istVorneFrei()){
                    einsVor();
                }
                else{
                    dreheUm();
                    while(istVorneFrei()){
                        einsVor();
                    }
                    rechtsUm();
                    einsVor();
                    rechtsUm();
                }
            }
            
                rechtsUm();
                einsVor();
                linksUm();
                einsVor();
                rechtsUm();
                while(!istBaumVorne()){
                    rechtsUm();
                    einsVor();
                    rechtsUm();
                    einsVor();
                    einsVor();
                    rechtsUm();
                    einsVor();
                    rechtsUm();
                    einsVor();
                    
                    
                    rechtsUm();
                    einsVor();
                    linksUm();
                    einsVor();
                    einsVor();
                    linksUm();
                    einsVor();
                    rechtsUm();
                }
                    rechtsUm();
                    einsVor();
                    rechtsUm();
                    einsVor();
                    einsVor();
                    rechtsUm();
                    einsVor();
                    rechtsUm();
                    einsVor();
                    
                    linksUm();
                    einsVor();
                    rechtsUm();
                    einsVor();
                    linksUm();
                    
                    while(!istBaumVorne()){
                        linksUm();
                        einsVor();
                        linksUm();
                        einsVor();
                        einsVor();
                        linksUm();
                        einsVor();
                        linksUm();
                        einsVor();
                        
                        
                        linksUm();
                        einsVor();
                        rechtsUm();
                        einsVor();
                        einsVor();
                        rechtsUm();
                        einsVor();
                        linksUm();
                    }
                    linksUm();
                        einsVor();
                        linksUm();
                        einsVor();
                        einsVor();
                        linksUm();
                        einsVor();
                        linksUm();
                        einsVor();
                        
                    }
                    
            }
        
            
                    
                    
      
 
    
