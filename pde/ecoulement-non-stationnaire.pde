/* @pjs pauseOnBlur=true; */
//=============================================================================
//Ecoulement non stationnaire autour d'un cylindre en mouvement dans un fluide parfait
//©J.Roussel -- 4 Janv. 2013

int OX, OY;			//Origine du repère
int w;				//largeur du sketch
int R;				//rayon du cylindre en pixels
int V0=6;			// vitesse du fluide loin
ArrayList particules;
int alpha=250;
boolean avecTrajectoire=false;
boolean playing=true;


void setup() {
	w=min(.8*window.innerWidth,600);
	size(w,w/2);
	colorMode(RGB, 256,256,256, 1);	
	R=height/8;
	frameRate(20);
	smooth();
	OX=0;OY=height/2;
	particules = new ArrayList();
	textAlign(CENTER,CENTER);
	for (int i=1;i<=50;i++){
		particules.add(new ParticuleFluide(width/2,height/51*i));
	}
}
void draw() {
	background(204,204,255,.5);
	//*** avec tracé de la trajectoire ***
	if(avecTrajectoire){
		for (int i = particules.size()-1; i >= 0; i--){
			ParticuleFluide PF = (ParticuleFluide) particules.get(i);
			PF.velocity=vitesse(PF.location.x, PF.location.y);
			PF.update();
			PF.displayTrajectoire();
		}
		if(playing){OX+=V0;OX=(OX+200)%(width+400)-200;}
		drawVitesse();
	}
	//*** sans tracé de la trajectoire ***
	if(!avecTrajectoire){
		for (int i = particules.size()-1; i >= 0; i--){
			ParticuleFluide PF = (ParticuleFluide) particules.get(i);
			PF.velocity=vitesse(PF.location.x, PF.location.y);
			PF.update();
			PF.display();
		}
		if(playing){OX+=V0;OX=(OX+200)%(width+400)-200;}
		drawVitesse();
	}	
	// //*** dessin du bouton reset ***
// 	if(buttonOver(mouseX,mouseY)){alpha=150;}
// 	else{alpha=250;}
// 	stroke(68);
// 	fill(0,153,204,alpha);
// 	rect(width-100,height-50,50,20,5);
// 	textSize(16);
// 	fill(255);
// 	text("Reset",width-75,height-40);
}
//	Champ Vecteur vitesse V(x,y) (en pixel par frame)
//	ATTENTION ! FAIRE: x=xx-OX et y=yy-OY
PVector vitesse(float xx, float yy) {
	if(sq(xx-OX)+sq(yy-OY)>sq(R))
	return new PVector(V0*((sq(xx-OX)-sq(yy-OY))*sq(R)/sq(sq(yy-OY)+sq(xx-OX))),2*V0*(xx-OX)*(yy-OY)*sq(R)/sq(sq(xx-OX)+sq(yy-OY)));
	else{return new PVector(0,0);}
}
//	tracé du vecteur vitesse
void drawVitesse() {
	strokeWeight(1);
	float intensity,len;
	for (int i=1;i<=width;i+=20)
		for (int j=1;j<=height;j+=20)
		{
		pushMatrix();
		translate(i, j);
		rotate(vitesse(i,j).heading2D()); // Scale it to be bigger or smaller if necessary
		intensity=map(vitesse(i,j).mag(),0,3,0.1,1);
		len=lerp(4, 16, intensity);
		line(0, 0, len, 0);
		fill(255,intensity);
		stroke(255,intensity);	
		triangle(len, 0, '.85'*len, 2, '.85'*len, -2);
		popMatrix();
		}
    fill(64);
	ellipse(OX,OY,2*R,2*R);
}
void mousePressed() {particules.add(new ParticuleFluide(mouseX, mouseY));}

void keyPressed() {
  if (key == 'T' || key == 't') {avecTrajectoire=!avecTrajectoire;} 
  if (key == 'R' || key == 'r'){ReInit();}
  if (key == 32) {playing=!playing;}		//keycode for space bar
}	

void AfficheTrace(){avecTrajectoire=!avecTrajectoire;}
void Marche(){playing=true;}
void Arret(){playing=false;}
void ReInit(){
	for (int i = particules.size()-1; i >= 0; i--) {
		particules.remove(i);
	}
}
class ParticuleFluide {
	PVector location;
  	PVector velocity;
  	int life = 200;
  	float[] ax = new float[life];
  	float[] ay = new float[life]; 
  
  	ParticuleFluide(float posX, float posY) {
		location = new PVector(posX, posY);
    	velocity = new PVector(0,0);
    	for (int i=0; i<life; i++) {
			ax[i] = posX;
      	  	ay[i] = posY;
		}
	}
	void update() {
		location.add(velocity);
    	ax[life-1] = location.x;
    	ay[life-1] = location.y;
    	for (int i=1; i<life; i++) {
			ax[i-1] = ax[i];
      	  	ay[i-1] = ay[i];
		}
	}
	void display() {
		noStroke();
		for (int j=1;j<5;j++){
			float transp=1/sq(j);		  
		    fill(250,0,230,transp);
			ellipse(location.x, location.y,5*j,5*j);
		}
	}
    void displayTrajectoire() {
		noStroke();
		for (int j=1;j<5;j++){
			float transp=1/sq(j);
		    fill(250,0,230,transp);
			ellipse(location.x, location.y,5*j,5*j);
		}
		strokeWeight(2);
		noFill();	
    	stroke(255,0,230,.25);	
    	beginShape();
		for (int i=1; i<life; i++) {vertex(ax[i-1], ay[i-1]);}
		endShape();
	}
}