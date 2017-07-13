class Stars {
  int num;
  
  PVector [] pos;
  PVector [] star;
  
  Stars(int num) {
    this.num = num;
    pos = new PVector[num];
    star = new PVector[num];
    for (int i = 0; i < num; i++) {
      pos[i] = new PVector(random(-width * 3.5, width * 3.5), random(-height * 3, height * 3), random(-8000, -2000));
      star[i] = new PVector(random(4, 14), random(35, 230));
    }
  }
  
  void drawStars() {
    for (int i = 0; i < num; i++) {
      noStroke();
      fill(240, star[i].y);
      pushMatrix();
      translate(0, 0, pos[i].z);
      ellipse(pos[i].x, pos[i].y, star[i].x, star[i].x);
      popMatrix();
    }
  }
  

  
}