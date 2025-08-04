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

	private Radio radio = new Radio();

	private void populate(VBox root) {
		original(root);
		
		var valueFactory = new IntegerSpinnerValueFactory(1, 10);
		var spinner = new Spinner<Integer>(valueFactory);
		spinner.setMaxWidth(100);
		spinner.valueProperty().addListener(new ChangeListener<Integer>() {
			@Override
			public void changed(ObservableValue<? extends Integer> obs, Integer old, Integer novel) {
				radio.setFrequency(novel);
			}
		});
		var hradio = new HBox(new Label("Radio channel:"), spinner);
		hradio.setAlignment(Pos.CENTER_LEFT);
		hradio.setSpacing(10);
		root.getChildren().add(hradio);
	}
}
