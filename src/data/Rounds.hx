package data;

import core.Wave.WaveStats;
import data.Global.ElementKey;

typedef OpponentConfig = {
	name:String,
	imageKey:ElementKey,
	waves:Array<WaveStats>
}

class Rounds {
	public static var opponents:Array<OpponentConfig> = [
		{
			name: "Bob the belidgerent",
			imageKey: BOB,
			waves: [
				{
					launchers: [
						Barracks.Launchers[KENNEL],
					],
					maximumActiveLaunchers: 2,
				},
				{
					launchers: [
						Barracks.Launchers[CAVALRY],
						Barracks.Launchers[CAVALRY],
						Barracks.Launchers[CAVALRY],
					],
					maximumActiveLaunchers: 2,
				},
			]
		},
		{
			name: "Karl of the Kabal",
			imageKey: BOB,
			waves: [
				{
					launchers: [
						Barracks.Launchers[CAVALRY],
						Barracks.Launchers[CAVALRY],
						Barracks.Launchers[CAVALRY]
					],
					maximumActiveLaunchers: 2,
				},
				{
					launchers: [
						Barracks.Launchers[CAVALRY],
						Barracks.Launchers[CAVALRY],
						Barracks.Launchers[CAVALRY],
					],
					maximumActiveLaunchers: 2,
				},
			]
		}
	];
}