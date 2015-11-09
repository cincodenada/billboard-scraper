<html>
  <head>
    <meta charset="utf-8" />
    <title>Most of the #1 Billboard Hits I could find on Wikipedia</title>
    <script type="text/javascript" src="http://code.jquery.com/jquery-2.1.4.js"></script>
    <link rel="stylesheet" href="//cdn.datatables.net/1.10.9/css/jquery.dataTables.min.css"/>
    <link rel="stylesheet" href="//cdn.datatables.net/1.10.9/css/jquery.dataTables.min.css"/>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">
    <script type="text/javascript" src="//cdn.datatables.net/1.10.9/js/jquery.dataTables.min.js"></script>
    <style>
      .popup {
        display: none;
        position: absolute;
        top: 0px;
        right: 0px;
        background: white;
        border: 2px solid black;
        padding: 5px;
        width: 500px;
      }

      .dataTables_wrapper .dataTables_filter { float: left; }
      .dataTables_wrapper .dataTables_length { float: right; }
    </style>
  </head>
  <body>
    <pre style="display: none">
    <?php
      $fh = fopen('linkmap.tsv','r');
      $links = array();
      while($row = fgetcsv($fh, 10000, "\t")) {
        $links[$row[0]] = $row[1];
      }

      $fh = fopen('songs.tsv','r');
      $songs = array();
      while($row = fgetcsv($fh, 10000, "\t", "\0")) {
        if(empty($row[0]) && empty($row[1]) && empty($row[2])) {
          continue;
        }
        // Explode out the sources
        $sources = array();
        foreach(explode('; ', $row[2]) as $sourcedate) {
          list($source, $date) = explode(', ', $sourcedate, 2);
          if(empty($date)) { var_dump($row); print "<$sourcedate>\n"; }
          $sources[] = array(
            'source' => $source,
            'date' => $date,
            'link' => $links[$source],
          );
        }
        $row[2] = $sources;

        $songs[] = $row;
      }
    ?>
    </pre>
    <header class="navbar navbar-static-top navbar-default">
        <div class="container">
            <div class="navbar-header">
                <a class="navbar-brand">
                    Most of the #1 Billboard Hits I could find on Wikipedia 
                </a>
            </div>
            <nav id="bs-navbar" class="collapse navbar-collapse">
                <ul class="nav navbar-nav navbar-right">
                    <li>
                        <a class="btn" href="https://github.com/cincodenada/billboard-scraper"><i class="fa fa-github"></i> GitHub</a>
                    </li>
                    <li>
                        <a class="btn" href="songs.tsv"><i class="fa fa-download"></i> Download the source TSV for use in Excel, etc</a>
                    </li>
                </ul>
            </nav>
        </div>
    </header>
    <div class="container">
        <div class="row">
            <div class="col-md-12">
                <div class="panel panel-default">
                    <div class="panel-body">
                        <p>
                            <b>Quick start:</b> No guarantees, but this should be a good place to start.
                            Search with the box on the left that should appear shortly,
                            hover over the number on the right to see where they came from.
                        </p>
                        <p>I parsed through all the Billboard charts I could find on Wikipedia, and the data should be pretty clean now.  There are some duplicates because of
                        different spellings (e.g. "'NSync" vs "'N Sync" or "Black Eyed Peas" vs "The Black Eyed Peas"), but those shouldn't pose too much of a problem
                        for the purposes of looking things up.</p> 
                        <p>I do not guarantee that all songs here are actually #1 Billboard Hits, and certainly not all the #1 Billboard Hits are here.  I may have picked
                        up some erroneous songs here or there, there were a lot of songs (over 7,000 or so).  Fortunately, if you hover over the number on the far right,
                        it will tell you what chart (or charts) I got that song from, with a link straight to the Wikipedia page, so you can double-check there to confirm.</p>
                        <p>Have fun, and good luck!</p>
                    </div>
                </div>
            </div>
            <div class="col-md-12">
                <table>
                  <thead>
                    <tr>
                      <th>Artist</th>
                      <th>Song</th>
                      <th>Source chart(s)</th>
                  </thead>
                  <tbody>
                    <?php foreach($songs as $row): ?>
                    <tr>
                      <td><?=$row[0]?></td>
                      <td><?=$row[1]?></td>
                      <td style="position: relative">
                        <a href="" class="refcount">[<?=count($row[2])?>]</a>
                        <div class="popup">
                          <?php foreach($row[2] as $source): ?>
                          <a href="http://en.wikipedia.org/wiki/<?=$source['link']?>">
                            <?=$source['source']?></a>
                          <?=$source['date']?>
                          <br/>
                          <?php endforeach ?>
                        </div>
                      </td>
                    </tr>
                    <?php endforeach ?>
                  </tbody>
                </table>
            </div>
        </div>
    </div>
    <script type="text/javascript">
      $('table').DataTable({
        dom: 'flrtip',
        lengthMenu: [100,500,1000,5000],
        language: {
          search: 'Search by song, artist, or chart:',
        }
      }); 
      $('table').on('mouseenter', '.refcount', function() {
        this.nextElementSibling.style.display = 'block';
      });
      $('table').on('mouseleave', '.popup', function() {
        this.style.display = 'none';
      });
    </script>
  </body>
</html>
