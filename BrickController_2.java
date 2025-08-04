package brickcontroller.framework;

import java.util.Collections;
import java.util.List;
import java.util.ServiceLoader;
import java.util.ServiceLoader.Provider;
import java.util.stream.Collectors;

import javafx.application.Application;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

public class BrickController extends Application {

	private static List<UfxPlugin> plugins = Collections.emptyList();

	public static void main(String[] args) {
		System.err.println("[INFO]: Loading plugins");
        //collect list of plugin instances
		plugins = ServiceLoader.load(UfxPlugin.class)
				.stream()
				.map(Provider::get)
				.collect(Collectors.toList());
		for (UfxPlugin plugin : plugins)
			System.err.println("[INFO]: Loaded "
					+plugin.getClass().getCanonicalName());
		launch(args);
	}

	public BrickController() {}

	public final static String LIGHTSTYLE = "-fx-background-color: #00D000; ";

	@Override
	public final void start(Stage primaryStage) {
		primaryStage.setTitle("Brick Controller");
		VBox root = new VBox();
		root.setPadding(new Insets(10));
		root.setSpacing(10);
		root.setAlignment(Pos.CENTER_LEFT);
		primaryStage.setScene(new Scene(root, 250, 150));

		for (UfxPlugin p : plugins)
			p.populate(root);

		primaryStage.show();
	}

}
