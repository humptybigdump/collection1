package brickcontroller.decorator;

import brickcontroller.decorator.features.Emergency;
import brickcontroller.decorator.features.Light;
import brickcontroller.decorator.features.Radio;
import javafx.application.Application;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

public class BrickController extends Application {
	
	private PopulationComponent component=null;
	
	public static void main(String[] args) {		
		launch(args);
	}

	public BrickController() {
		component=new Radio(new Radio(new Light()));
		//minimal product
		//strategy=new Light();
		//variants
		//strategy=new Radio();
		//strategy=new Emergency();
		//strategy=new RadioAndEmergency();
	}

	public final static String LIGHTSTYLE = "-fx-background-color: #00D000; ";

	@Override
	public final void start(Stage primaryStage) {
		primaryStage.setTitle("Brick Controller");
		VBox root = new VBox();
		root.setPadding(new Insets(10));
		root.setSpacing(10);
		root.setAlignment(Pos.CENTER_LEFT);
		primaryStage.setScene(new Scene(root, 250, 150));
		
		if (component!=null)
			component.populate(root);

		primaryStage.show();
	}

}
