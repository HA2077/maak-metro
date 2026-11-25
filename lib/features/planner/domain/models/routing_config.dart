class RoutingConfig {
  const RoutingConfig({
    this.perStopMinutes = 2.5,
    this.transferPenaltyMinutes = 7.5,
  });

  final double perStopMinutes;
  final double transferPenaltyMinutes;
}
