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

public class BrickController extends Application {

	private Emergency emergency = new Emergency();

	private void populate(VBox root) {
		original(root);

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
}
