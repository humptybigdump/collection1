package brickcontroller.observer;

import java.util.ArrayList;
import java.util.List;

import brickcontroller.observer.features.Emergency;
import brickcontroller.observer.features.Light;
import brickcontroller.observer.features.Radio;
import javafx.application.Application;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

public class BrickController extends Application {
	
	private static List<StartObserver> OBSERVERS=new ArrayList<>();
	public static void register(StartObserver obs) { OBSERVERS.add(obs); }

	public static void main(String[] args) {
		register(new Emergency());
		register(new Light());
		//register(new Radio());		
		launch(args);
	}

	public BrickController() {
	}

	public final static String LIGHTSTYLE = "-fx-background-color: #00D000; ";

	@Override
	public void start(Stage primaryStage) {
		primaryStage.setTitle("Brick Controller");
		VBox root = new VBox();
		root.setPadding(new Insets(10));
		root.setSpacing(10);
		root.setAlignment(Pos.CENTER_LEFT);
		primaryStage.setScene(new Scene(root, 250, 150));

		//notify registered features
		for (StartObserver obs:OBSERVERS) {
			obs.notifyStart(root);
		}

		primaryStage.show();
	}
}
