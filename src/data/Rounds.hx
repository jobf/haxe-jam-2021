package data;

import core.Wave.WaveStats;
import data.Global.ElementKey;

typedef OpponentConfig = {
	name:String,
	imageKey:ElementKey,
	waves:Array<WaveStats>
}

/*

new Vector2(item.body.x, item.body.y)
*/

class Rounds {
	public static var opponents:Array<OpponentConfig> = [
		{
			name: "Bob the belidgerent",
			imageKey: BOB,
			waves: [
				{
					launchers: [
						{ pos: null, stats: Barracks.Launchers[lBUBBLER]},
					],
					maximumActiveLaunchers: 1,
				}
			]
		},
		{
			name: "Knights Who Say \"Ni!\"",
			imageKey: BOB,
			waves: [
				{
					launchers: [
						{ pos: null, stats: Barracks.Launchers[lBUILDING]},
					],
					maximumActiveLaunchers: 1,
				}
			]
		},
		{
			name: "Tights in the hood",
			imageKey: BOB,
			waves: [
				{
					launchers: [
						{ pos: null, stats: Barracks.Launchers[lFOWLER]},
						{ pos: null, stats: Barracks.Launchers[lARCHER]},
						{ pos: null, stats: Barracks.Launchers[lARCHER]},
						{ pos: null, stats: Barracks.Launchers[lBUBBLER]},
					],
					maximumActiveLaunchers: 2,
				},
				{
					launchers: [
						{ pos: null, stats: Barracks.Launchers[lBUILDING]},
						{ pos: null, stats: Barracks.Launchers[lARCHER]},
						{ pos: null, stats: Barracks.Launchers[lFOWLER]},
						{ pos: null, stats: Barracks.Launchers[lARCHER]},
					],
					maximumActiveLaunchers: 2,
				},
			]
		}
	];
}