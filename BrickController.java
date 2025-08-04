package brickcontroller;

import javafx.application.Application;
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

public class BrickController extends Application {

	public class Light {
		private boolean on = false;

		public boolean toggle() {
			on = !on;
			return on;
		}
	}

	public class Radio {
		private int frequency = 1;

		public int getFrequency() {
			return frequency;
		}

		public void setFrequency(int f) {
			if (f > 0 && f < 11)
				frequency = f;
		}
	}

	public class Emergency {
		private boolean light = false;
		private boolean siren = false;

		public boolean toggleLight() {
			light = !light;
			return light;
		}

		public boolean toggleSiren() {
			siren = !siren;
			return siren;
		}
	}

	public static void main(String[] args) {
		launch(args);
	}

	public BrickController() {
	}

	final String lightstyle = "-fx-background-color: #00D000; ";
	private Light light = new Light();
	private Radio radio = new Radio();
	private Emergency emergency = new Emergency();

	@Override
	public void start(Stage primaryStage) {
		primaryStage.setTitle("Brick Controller");
		VBox root = new VBox();
		root.setPadding(new Insets(10));
		root.setSpacing(10);
		root.setAlignment(Pos.CENTER_LEFT);
		
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

		var valueFactory = new IntegerSpinnerValueFactory(1, 10);
		var spinner = new Spinner<>(valueFactory);
		spinner.setMaxWidth(100);
		spinner.valueProperty().addListener((observableValue, oldValue, newValue) -> radio.setFrequency(newValue));
		var hradio = new HBox(new Label("Radio channel:"), spinner);
		hradio.setAlignment(Pos.CENTER_LEFT);
		hradio.setSpacing(10);
		root.getChildren().add(hradio);

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

		primaryStage.setScene(new Scene(root, 250, 150));
		primaryStage.show();
	}
}
