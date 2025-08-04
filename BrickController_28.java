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

	private Light light = new Light();
	
	private void populate(VBox root) {
		original(root);
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
}
