# System architecture

```text
             Synthetic mobility + channel scenarios
                           |
                           v
          Feature extraction (position, speed, bearing,
             blockage, estimated SNR, distance)
                           |
                           v
                Feedforward Neural Network
                  (ReLU + Softmax, 8 classes)
                           |
                           v
                Predicted beam index
                           |
             +-------------+-------------+
             |                           |
             v                           v
     Adaptive beam output        Conventional baseline
                                (strongest measured RSSI)
             |                           |
             +-------------+-------------+
                           |
                           v
           RSSI / SNR / throughput / outage /
              switching / accuracy metrics
                           |
                           v
               Dashboard + plots + CSV
```

## Flow
1. Generate labelled samples from the directional link model.
2. Split into training, validation and held-out test partitions.
3. Normalize features using training-set statistics.
4. Train a small feedforward neural network using mini-batch gradient descent.
5. Predict a beam during each simulation time step.
6. Run the baseline on the identical channel trace.
7. Compare the resulting link and mobility metrics.
