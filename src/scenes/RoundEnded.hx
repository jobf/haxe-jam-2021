package scenes;

import data.Rounds;
import lime.graphics.Image;
import ob.pear.UI.ButtonGrid;

class RoundEnded extends BaseScene {
	override public function new(pear:Pear, images:Map<ElementKey, Image>) {
		super(pear, images);
	}

	override function init() {
		super.init();

		var title = vis.text.write("Round is over ...", pear.window.width * 0.5, Global.margin * 3, Global.textBgColor);

		if (Global.whoWonLastRound != 0) {
				var winner = Global.whoWonLastRound == PlayerId.A ? "YOU" : Rounds.opponents[Global.opponentIndex].name;
			vis.text.write('$winner was victorious!', pear.window.width * 0.5, title.y + (title.get_height() * 3) + Global.margin, Global.textBgColor);
		}

		var container = {
			x: 350.0,//pear.window.width * 0.5 - (pear.window.width * 0.25),
			y: pear.window.height * 0.5,
			w: pear.window.width * 0.5,
			h: pear.window.height * 1.0,
			margin: Global.margin
		};

		var playButton = Global.whoWonLastRound == PlayerId.A ? {
			text: "NEXT!",
			action: (b) -> {
				pear.changeScene(new WaveSetupScene(pear, images));
			}
		} : {
			text: "AGAIN!",
			action: (b) -> {
				pear.changeScene(new ScorchedEarth(pear, images));
			}
			};

		var quitButton = {
			text: "QUIT!",
			action: (b) -> {
				pear.changeScene(new Title(pear, images));
			}
		};

		var buttons = [];

		if (Global.opponentIndex > Rounds.opponents.length - 1) {
				// you won the game...
			vis.text.write('YOU defeated them all to become the OVERLORD', pear.window.width * 0.5, title.y + title.get_height() * 6 + Global.margin, Global.textBgColor);
			buttons.push(quitButton);
		} else {
			buttons.push(playButton);
			buttons.push(quitButton);
		}

		var grid = new ButtonGrid(pear, clickHandler, buttons, container);
	}
}
