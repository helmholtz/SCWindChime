Ball2 {
	var <>position;
	var <>velocity;

	*new { |pos, vel|
		^super.newCopyArgs(pos, vel);
	}

	updatePosition {|speed=1|
		this.position = speed*this.velocity + this.position;
	}
}

Polygon {
	var <sides, <radius, <points, <perps;

	*new {|n, width, height|
		var radius = min(width/2, height/2);
		var points = Array.fill(n, {|i|
			radius * Point(cos((2pi*i)/n), sin((2pi*i)/n))
		});
		var perps = Array.fill(n, {|i|
			var firstPoint = points[i];
			var secondPoint = points.wrapAt(i+1);
			var tempPoint = firstPoint + secondPoint;
			tempPoint / tempPoint.rho;
		});

		^super.newCopyArgs(n, radius, points, perps);
	}
}

WindChime {
	var <>ball;
	var <>polygon;
	var <loudness = 0;
	var <brightness = 0;

	*new {|b, p|
		^super.newCopyArgs(b, p);
	}

	getSector {
		var theta = ball.position.theta;
		(theta < 0).if({ theta = theta + 2pi });
		^(polygon.sides * theta / 2pi).floor;
	}

	isOutside {|side|
		var det = {|a,b| (a.x * b.y) - (a.y * b.x)};
		var firstPoint = polygon.points[side];
		var secondPoint = polygon.points.wrapAt(side+1);
		^(det.value(secondPoint-firstPoint, secondPoint-ball.position) > 0);  //True if ball is outside
	}

	updateVelocity {|side, elasticity|
		var dot = {|a,b| (a.x * b.x) + (a.y * b.y)};
		var component = dot.value(ball.velocity, polygon.perps[side]);
		var rightDistance = ball.position.dist(polygon.points[side]);
		var leftDistance = ball.position.dist(polygon.points.wrapAt(side+1));

		(component > 0).if(
			{ ball.velocity = ball.velocity - ((1+elasticity) * component * polygon.perps[side]) },
			{ ball.velocity }
		);

		loudness = component.abs;
		brightness = min(rightDistance, leftDistance)/max(rightDistance, leftDistance);
	}

}