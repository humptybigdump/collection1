package brickcontroller; 

import javafx.application.Application; 
import javafx.beans.value.ChangeListener; 
import javafx.beans.value.ObservableValue; 
import javafx.event.ActionEvent; 
import javafx.event.EventHandler; 
import javafx.geometry.Insets; 
import javafx.geometry.Pos; 
import javafx.scene.Scene; 
import javafx.scene.control.Button; 
import javafx.scene.control.Label; 
import javafx.scene.control.Spinner; 
import javafx.scene.control.SpinnerValueFactory.IntegerSpinnerValueFactory; 
import javafx.scene.layout.HBox; 
import javafx.scene.layout.VBox; 
import javafx.stage.Stage; 

public   class  BrickController  extends Application {
	

	public static void main(String[] args) {
		launch(args);
	}

	

	public BrickController() {
	}

	

	final String lightstyle = "-fx-background-color: #00D000; ";

	
	
	@Override
	public void start(Stage primaryStage) {
		primaryStage.setTitle("Brick Controller");
		VBox root = new VBox();
		root.setPadding(new Insets(10));
		root.setSpacing(10);
		root.setAlignment(Pos.CENTER_LEFT);

		populate(root);
		
		primaryStage.setScene(new Scene(root, 250, 150));
		primaryStage.show();
	}

	
	
	 private void  populate__wrappee__BrickController(VBox root) {
		//Hook Method
	}

	
	
	 private void  populate__wrappee__Light(VBox root) {
		populate__wrappee__BrickController(root);
		var lightswitch = new Button("On/Off");
		lightswitch.setOnAction(new EventHandler<ActionEvent>() {
			@Override
			public void handle(ActionEvent event) {
				lightswitch.setStyle(light.toggle() ? lightstyle : "");
			}
		});
		var hlight = new HBox(new Label("Light:"), lightswitch);
		hlight.setAlignment(Pos.CENTER_LEFT);
		hlight.setSpacing(10);
		root.getChildren().add(hlight);		
	}

	

	private void populate(VBox root) {
		populate__wrappee__Light(root);

		var emergencyLight = new Button("Lights");
		emergencyLight.setOnAction(new EventHandler<ActionEvent>() {
			@Override
			public void handle(ActionEvent event) {
				emergencyLight.setStyle(emergency.toggleLight() ? lightstyle : "");
			}
		});
		var emergencySiren = new Button("Siren");
		emergencySiren.setOnAction(new EventHandler<ActionEvent>() {
			@Override
			public void handle(ActionEvent event) {
				emergencySiren.setStyle(emergency.toggleSiren() ? lightstyle : "");
			}
		});
		var hemergency = new HBox(new Label("Emergency:"), emergencyLight, emergencySiren);
		hemergency.setAlignment(Pos.CENTER_LEFT);
		hemergency.setSpacing(10);
		root.getChildren().add(hemergency);
	}

	

	private Light light = new Light();

	

	private Emergency emergency = new Emergency();


}
