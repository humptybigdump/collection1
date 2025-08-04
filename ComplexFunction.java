package sum;

import java.util.function.Function;

public class ComplexFunction implements Function<Integer, Double> {

    @Override
    public Double apply(Integer integer) {
        double res = integer;
        for (int i = 0; i < integer; i++) {
            res = Math.sqrt(res);
        }

        return res;
    }
}