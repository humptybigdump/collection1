package brickcontroller;

import javafx.application.Application;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Node;
import javafx.scene.Scene;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;
import javafx.scene.layout.VBox;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.scene.control.Button;
import javafx.scene.layout.VBox;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.Pos;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;

public class BrickController extends Application {

	public static void main(String[] args) {
		launch(args);
	}

	public BrickController() {
	}

	public static final String LIGHTSTYLE = "-fx-background-color: #00D000; ";

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

	public void addTo(VBox root, Node node) {
		root.getChildren().add(node);
	}

	private void populate(VBox root) {
		// modified content
		Button lightswitch = new Button("On/Off");
		lightswitch.setOnAction(new EventHandler<ActionEvent>() {
			public void handle(ActionEvent event) {
				lightswitch.setStyle(light.toggle() ? "-fx-background-color: #00D000; " : "");
			}
		});
		HBox hlight = new HBox(new Label("Light:"), lightswitch);
		hlight.setAlignment(Pos.CENTER_LEFT);
		hlight.setSpacing(10);
		addTo(root, lightswitch);
		populate$PopulateLight(root);
		//Hook Method
	}

	private Emergency emergency = new Emergency();

	private void populate$PopulateEmergency(VBox root) {
		//Hook Method
	}

	private Light light = new Light();

	private void populate$PopulateLight(VBox root) {
		// modified content
		Button emergencyLight = new Button("Lights");
		emergencyLight.setOnAction(new EventHandler<ActionEvent>() {
			public void handle(ActionEvent event) {
				emergencyLight.setStyle(emergency.toggleLight() ? "-fx-background-color: #00D000; " : "");
			}
		});
		Button emergencySiren = new Button("Siren");
		emergencySiren.setOnAction(new EventHandler<ActionEvent>() {
			public void handle(ActionEvent event) {
				emergencySiren.setStyle(emergency.toggleSiren() ? "-fx-background-color: #00D000; " : "");
			}
		});
		HBox hemergency = new HBox(new Label("Emergency:"), emergencyLight, emergencySiren);
		hemergency.setAlignment(Pos.CENTER_LEFT);
		hemergency.setSpacing(10);
		addTo(root, hemergency);
		populate$PopulateEmergency(root);
		//Hook Method
	}
}
