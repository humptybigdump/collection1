package edu.kit.kastel.util;

import edu.kit.kastel.Main;
import edu.kit.kastel.model.Node;

import java.util.ArrayDeque;
import java.util.HashMap;
import java.util.Map;
import java.util.Queue;

/**
 * The BFS algorithm for finding the shortest path on a terrain.
 *
 * @author uezxa
 * @author udkdm
 */
public final class BreadthFirstSearch {

    private BreadthFirstSearch() {
        throw new AssertionError(Main.ERROR_UTILITY_CLASS);
    }

    /**
     * Performs a breadth first search starting at the given start vertex. The search results
     * in a search tree represented by a parent map.
     *
     * @param start The vertex to start the search from
     * @return The parent map
     */
    public static Map<Node, Node> bfs(Node start) {
        //key is child, value is parent
        Map<Node, Node> parents = new HashMap<>();
        Queue<Node> queue = new ArrayDeque<>();
        queue.add(start);

        while (!queue.isEmpty()) {
            Node currentNode = queue.remove();
            for (Node neighbour : currentNode.getNeighbours()) {
                if (parents.containsKey(neighbour)) {
                    continue;
                }
                queue.add(neighbour);
                parents.put(neighbour, currentNode);
            }
        }
        return parents;
    }
}
