enum Location { GOR, FAL, LAD, CTY, WTH, KIN, NON }

class Locations
{

  static const list = <String> ['Gorton', 'Fallowfield','Ladybarn','City Centre','Withington','Kingsway','None'];

  static String text( Location l)
  {
    switch( l ) {
      case Location.GOR:
        return 'Gorton';
      case Location.FAL:
        return 'Fallowfield';
      case Location.LAD:
        return 'Ladybarn';
      case Location.CTY:
        return 'City Centre';
      case Location.WTH:
        return 'Withington';
      case Location.KIN:
        return 'Kingsway';
      case Location.NON:
        return 'None';
    }
  }

  static Location fromText( String l)
  {
    switch( l ) {
      case 'Gorton':
        return Location.GOR;
      case 'Fallowfield':
        return Location.FAL;
      case 'Ladybarn':
        return Location.LAD;
      case 'City Centre':
        return Location.CTY;
      case 'Withington':
        return Location.WTH;
      case 'Kingsway':
        return Location.KIN;
      case 'None':
        return Location.NON;
    }
  }

  static List<String> list2() {
    return ['Gorton', 'Fallowfield','Ladybarn','City Centre','Withington','Kingsway','None'];
  }

}
