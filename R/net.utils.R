# Exported Functions ------------------------------------------------------

#' @title Check Degree Distribution for Balance in Target Statistics
#'
#' @description Checks for consistency in the implied network statistics
#'              of a two-group network in which the group size and
#'              group-specific degree distributions are specified.
#'
#' @param num.g1 Number of nodes in group 1.
#' @param num.g2 Number of nodes in group 2.
#' @param deg.dist.g1 Vector with fractional degree distribution for group 1.
#' @param deg.dist.g2 Vector with fractional degree distribution for group 2.
#'
#' @details
#' This function outputs the number of nodes of degree 0 to g, where g is the
#' length of a fractional degree distribution vector, given that vector and the
#' size of the group. This utility is used to check for balance in implied
#' degree given that fractional distribution within two-group network
#' simulations, in which the degree-constrained counts must be equal across
#' groups.
#'
#' @export
#' @keywords netUtils
#'
#' @examples
#' # An unbalanced distribution
#' check_degdist_bal(num.g1 = 500, num.g2 = 500,
#'                   deg.dist.g2 = c(0.40, 0.55, 0.03, 0.02),
#'                   deg.dist.g1 = c(0.48, 0.41, 0.08, 0.03))
#'
#' # A balanced distribution
#' check_degdist_bal(num.g1 = 500, num.g2 = 500,
#'                   deg.dist.g1 = c(0.40, 0.55, 0.04, 0.01),
#'                   deg.dist.g2 = c(0.48, 0.41, 0.08, 0.03))
#'
check_degdist_bal <- function(num.g1, num.g2,
                              deg.dist.g1, deg.dist.g2) {
  deg.counts.g1 <- deg.dist.g1 * num.g1
  deg.counts.g2 <- deg.dist.g2 * num.g2
  tot.deg.g1 <- sum(deg.counts.g1 * (1:length(deg.dist.g1) - 1))
  tot.deg.g2 <- sum(deg.counts.g2 * (1:length(deg.dist.g2) - 1))
  mat <- matrix(c(deg.dist.g1, deg.counts.g1,
                  deg.dist.g2, deg.counts.g2), ncol = 4)
  mat <- rbind(mat, c(sum(deg.dist.g1), tot.deg.g1, sum(deg.dist.g2),
                      tot.deg.g2))
  colnames(mat) <- c("g1.dist", "g1.cnt", "g2.dist", "g2.cnt")
  rownames(mat) <- c(paste0("Deg", 0:(length(deg.dist.g1) - 1)), "Edges")
  cat("Degree Distribution Check\n")
  cat("=============================================\n")
  print(mat, print.gap = 3)
  cat("=============================================\n")
  reldiff <- (tot.deg.g1 - tot.deg.g2) / tot.deg.g2
  absdiff <- abs(tot.deg.g1 - tot.deg.g2)
  if (sum(deg.dist.g1) <= 0.999 | sum(deg.dist.g1) >= 1.001 |
      sum(deg.dist.g2) <= 0.999 | sum(deg.dist.g2) >= 1.001 | absdiff > 1) {
    if (sum(deg.dist.g1) <= 0.999 | sum(deg.dist.g1) >= 1.001) {
      cat("** deg.dist.g1 TOTAL != 1 \n")
    }
    if (sum(deg.dist.g2) <= 0.999 | sum(deg.dist.g2) >= 1.001) {
      cat("** deg.dist.g2 TOTAL != 1 \n")
    }
    if (absdiff > 1) {
      if (tot.deg.g1 > tot.deg.g2) {
        msg <- "Group 1 Edges > Group 2 Edges:"
      } else {
        msg <- "Group 1 Edges < Group 2 Edges:"
      }
      cat("**", msg, round(reldiff, 3), "Rel Diff \n")
    }
  } else {
    cat("** Edges balanced ** \n")
  }
  invisible(c(tot.deg.g1, deg.counts.g1, deg.counts.g2))
}


#' @title Creates a TEA Variable for Infection Status for \code{ndtv} Animations
#'
#' @description Creates a new color-named temporally-extended attribute (TEA)
#'              variable in a \code{networkDynamic} object containing a disease
#'              status TEA in numeric format.
#'
#' @param nd An object of class \code{networkDynamic}.
#' @param old.var Old TEA variable name.
#' @param old.sus Status value for susceptible in old TEA variable.
#' @param old.inf Status value for infected in old TEA variable.
#' @param old.rec Status value for recovered in old TEA variable.
#' @param new.var New TEA variable name to be stored in \code{networkDynamic}
#'        object.
#' @param new.sus Status value for susceptible in new TEA variable.
#' @param new.inf Status value for infected in new TEA variable.
#' @param new.rec Status value for recovered in new TEA variable.
#' @param verbose Print progress to console.
#'
#' @details
#' The \code{ndtv} package (\url{https://cran.r-project.org/package=ndtv})
#' produces animated visuals for dynamic networks with evolving edge structures
#' and nodal attributes. Nodal attribute dynamics in \code{ndtv} movies require
#' a temporally extended attribute (TEA) containing a standard R color for each
#' node at each time step. By default, the \code{EpiModel} package uses TEAs to
#' store disease status history in network model simulations run in
#' \code{\link{netsim}}. But, that status TEA is in numeric format (0, 1, 2).
#' The \code{color_tea} function transforms those numeric values of that disease
#' status TEA into a TEA with color values in order to visualize status changes
#' in \code{ndtv}.
#'
#' The convention in \code{\link{plot.netsim}} is to color the susceptible
#' nodes as blue, infected nodes as red, and recovered nodes as green. Alternate
#' colors may be specified using the \code{new.sus}, \code{new.inf}, and
#' \code{new.rec} parameters, respectively.
#'
#' Using the \code{color_tea} function with a \code{netsim} object requires that
#' TEAs for disease status be used and that the \code{networkDynamic} object be
#' saved in the output: \code{tergmListe} must be  set to \code{FALSE} in
#' \code{\link{control.net}}.
#'
#' @seealso \code{\link{netsim}} and the \code{ndtv} package documentation.
#' @keywords colorUtils
#' @export
#'
color_tea <- function(nd, old.var = "testatus", old.sus = "s", old.inf = "i",
                      old.rec = "r", new.var = "ndtvcol", new.sus, new.inf,
                      new.rec, verbose = TRUE) {
  if (missing(new.inf)) {
    new.inf <- adjustcolor(2, 0.75)
  }
  if (missing(new.sus)) {
    new.sus <- adjustcolor(4, 0.75)
  }
  if (missing(new.rec)) {
    new.rec <- adjustcolor(3, 0.75)
  }
  times <- 1:max(get.change.times(nd))
  for (at in times) {
    stat <- get.vertex.attribute.active(nd, old.var, at = at)
    infected <- which(stat == old.inf)
    uninfected <- which(stat == old.sus)
    recovered <- which(stat == old.rec)
    nd <- activate.vertex.attribute(nd, prefix = new.var, value = new.inf,
                                    onset = at, terminus = Inf, v = infected)
    nd <- activate.vertex.attribute(nd, prefix = new.var, value = new.sus,
                                    onset = at, terminus = Inf, v = uninfected)
    nd <- activate.vertex.attribute(nd, prefix = new.var, value = new.rec,
                                    onset = at, terminus = Inf, v = recovered)
    if (verbose == TRUE) {
      cat("\n", at, "/", max(times), "\t", sep = "")
    }
  }
  return(nd)
}


#' @title Copies Vertex Attributes From Network to dat List
#'
#' @description Copies the vertex attributes stored on the network object to the
#'              master attr list in the dat data object.
#'
#' @param dat Master data object passed through \code{netsim} simulations.
#'
#' @seealso \code{\link{get_formula_term_attr}}, \code{\link{get_attr_prop}},
#'          \code{\link{auto_update_attr}}, and
#'          \code{\link{copy_datattr_to_nwattr}}.
#' @keywords netUtils internal
#' @export
#'
copy_nwattr_to_datattr <- function(dat) {
  otha <- names(dat$nw[[1]]$val[[1]])
  otha <- setdiff(otha, c("na", "vertex.names", "active",
                          "testatus.active", "tergm_pid"))
  if (length(otha) > 0) {
    for (i in seq_along(otha)) {
      va <- get_vertex_attribute(dat$nw[[1]], otha[i])
      dat$attr[[otha[i]]] <- va
      if (!is.null(dat$control$epi.by) && dat$control$epi.by == otha[i]) {
        dat$temp$epi.by.vals <- unique(va)
      }
    }
  }
  return(dat)
}


#' @title Copies Vertex Attributes from the dat List to the Network Object
#'
#' @description Copies the vertex attributes stored on the master attr list on
#'              dat to the network object on dat.
#'
#' @param dat Master data object passed through \code{netsim} simulations.
#'
#' @seealso \code{\link{get_formula_term_attr}}, \code{\link{get_attr_prop}},
#'          \code{\link{auto_update_attr}}, and
#'          \code{\link{copy_nwattr_to_datattr}}.
#' @keywords netUtils internal
#' @export
#'
copy_datattr_to_nwattr <- function(dat) {
  nwterms <- dat$temp$nwterms
  special.attr <- "status"
  if (dat$param$groups == 2) {
    special.attr <- c(special.attr, "group")
  }
  nwterms <- union(nwterms, special.attr)
  attr.to.copy <- union(nwterms, special.attr)
  attr <- dat$attr[attr.to.copy]
  if (length(attr.to.copy) > 0) {
    dat$nw[[1]] <- set_vertex_attribute(dat$nw[[1]], names(attr), attr)
  }

  return(dat)
}

#' @title Dissolution Coefficients for Stochastic Network Models
#'
#' @description Calculates dissolution coefficients, given a dissolution model
#'              and average edge duration, to pass as offsets to an ERGM/STERGM
#'              model fit in \code{netest}.
#'
#' @param dissolution Right-hand sided STERGM dissolution formula
#'        (see \code{\link{netest}}). See below for list of supported
#'        dissolution models.
#' @param duration A vector of mean edge durations in arbitrary time units.
#' @param d.rate Departure or exit rate from the population, as a single
#'        homogenous rate that applies to the entire population.
#'
#' @details
#' This function performs two calculations for dissolution coefficients
#' used in a network model estimated with \code{\link{netest}}:
#' \enumerate{
#'  \item \strong{Transformation:} the mean duration of edges in a network are
#'        mathematically transformed to logit coefficients.
#'  \item \strong{Adjustment:} in a dynamic network simulation in an open
#'        population (in which there are departures), it is further necessary to
#'        adjust these coefficients for dynamic simulations; this upward
#'        adjustment accounts for departure as a competing risk to edge
#'        dissolution.
#' }
#'
#' The current dissolution models supported by this function and in network
#' model estimation in \code{\link{netest}} are as follows:
#' \itemize{
#'  \item \code{~offset(edges)}: a homogeneous dissolution model in which the
#'         edge duration is the same for all partnerships. This requires
#'         specifying one duration value.
#'  \item \code{~offset(edges) + offset(nodematch("<attr>"))}: a heterogeneous
#'         model in which the edge duration varies by whether the nodes in the
#'         dyad have similar values of a specified attribute. The duration
#'         vector should now contain two values: the first is the mean edge
#'         duration of non-matched dyads, and the second is the duration of the
#'         matched dyads.
#'  \item \code{~offset(edges) + offset(nodemix("<attr>"))}: a heterogeneous
#'         model that extends the nodematch model to include non-binary
#'         attributes for homophily. The duration vector should first contain
#'         the base value, then the values for every other possible combination
#'         in the term.
#'  \item \code{~offset(edges) + offset(nodefactor("<attr>"))}: a heterogeneous
#'         model in which the edge duration varies by a specified attribute. The
#'         duration vector should first contain the base value, then the values
#'         for every other value of that attribute in the term.
#' }
#'
#' @return
#' A list of class \code{disscoef} with the following elements:
#' \itemize{
#'  \item \strong{dissolution:} right-hand sided STERGM dissolution formula
#'         passed in the function call.
#'  \item \strong{duration:} mean edge durations passed into the function.
#'  \item \strong{coef.crude:} mean durations transformed into logit
#'        coefficients.
#'  \item \strong{coef.adj:} crude coefficients adjusted for the risk of
#'        departure on edge persistence, if the \code{d.rate} argument is
#'        supplied.
#'  \item \strong{d.rate:} the departure rate.
#' }
#'
#' @export
#' @keywords netUtils
#'
#' @examples
#' ## Homogeneous dissolution model with no departures
#' dissolution_coefs(dissolution = ~offset(edges), duration = 25)
#'
#' ## Homogeneous dissolution model with departures
#' dissolution_coefs(dissolution = ~offset(edges), duration = 25,
#'                   d.rate = 0.001)
#'
#' ## Heterogeneous dissolution model in which same-race edges have
#' ## shorter duration compared to mixed-race edges, with no departures
#' dissolution_coefs(dissolution = ~offset(edges) + offset(nodematch("race")),
#'                   duration = c(20, 10))
#'
#' ## Heterogeneous dissolution model in which same-race edges have
#' ## shorter duration compared to mixed-race edges, with departures
#' dissolution_coefs(dissolution = ~offset(edges) + offset(nodematch("race")),
#'                   duration = c(20, 10), d.rate = 0.001)
#'
#' \dontrun{
#' ## Extended example for differential homophily by age group
#' # Set up the network with nodes categorized into 5 age groups
#' nw <- network_initialize(n = 1000)
#' age.grp <- sample(1:5, 1000, TRUE)
#' nw <- set_vertex_attribute(nw, "age.grp", age.grp)
#'
#' # durations = non-matched, age.grp1 & age.grp1, age.grp2 & age.grp2, ...
#' # TERGM will include differential homophily by age group with nodematch term
#' # Target stats for the formation model are overall edges, and then the number
#' #    matched within age.grp 1, age.grp 2, ..., age.grp 5
#' form <- ~edges + nodematch("age.grp", diff = TRUE)
#' target.stats <- c(450, 100, 125, 40, 80, 100)
#'
#' # Target stats for the dissolution model are duration of non-matched edges,
#'      then duration of edges matched within age.grp 1, age.grp 2, ...,
#'      age.grp 5
#' durs <- c(60, 30, 80, 100, 125, 160)
#' diss <- dissolution_coefs(~offset(edges) +
#'                             offset(nodematch("age.grp", diff = TRUE)),
#'                           duration = durs)
#'
#' # Fit the TERGM
#' fit <- netest(nw, form, target.stats, diss)
#'
#' # Full diagnostics to evaluate model fit
#' dx <- netdx(fit, nsims = 10, ncores = 4, nsteps = 300)
#' print(dx)
#'
#' # Simulate one long time series to examine timed edgelist
#' dx <- netdx(fit, nsims = 1, nsteps = 5000, keep.tedgelist = TRUE)
#'
#' # Extract timed-edgelist
#' te <- as.data.frame(dx)
#' head(te)
#'
#' # Limit to non-censored edges
#' te <- te[which(te$onset.censored == FALSE & te$terminus.censored == FALSE),
#'          c("head", "tail", "duration")]
#' head(te)
#'
#' # Look up the age group of head and tail nodes
#' te$ag.head <- age.grp[te$head]
#' te$ag.tail <- age.grp[te$tail]
#' head(te)
#'
#' # Recover average edge durations for age-group pairing
#' mean(te$duration[te$ag.head != te$ag.tail])
#' mean(te$duration[te$ag.head == 1 & te$ag.tail == 1])
#' mean(te$duration[te$ag.head == 2 & te$ag.tail == 2])
#' mean(te$duration[te$ag.head == 3 & te$ag.tail == 3])
#' mean(te$duration[te$ag.head == 4 & te$ag.tail == 4])
#' mean(te$duration[te$ag.head == 5 & te$ag.tail == 5])
#' durs
#' }
#'
dissolution_coefs <- function(dissolution, duration, d.rate = 0) {
  # Error check for duration < 1
  if (any(duration < 1)) {
    stop("All values in duration must be >= 1", call. = FALSE)
  }
  # Check form of dissolution formula
  form.length <- length(strsplit(as.character(dissolution)[2], "[+]")[[1]])
  t1.edges <- grepl("offset[(]edges",
                    strsplit(as.character(dissolution)[2], "[+]")[[1]][1])
  if (form.length == 2) {
    t2 <- strsplit(as.character(dissolution)[2], "[+]")[[1]][2]
    t2.term <- NULL
    if (grepl("offset[(]nodematch", t2)) {
      t2.term <- "nodematch"
    } else if (grepl("offset[(]nodefactor", t2)) {
      t2.term <- "nodefactor"
    } else if (grepl("offset[(]nodemix", t2)) {
      t2.term <- "nodemix"
    }
  }
  model.type <- NA
  if (form.length == 1 && t1.edges == TRUE) {
    model.type <- "homog"
  } else if (form.length == 2 && t1.edges == TRUE &&
             t2.term %in% c("nodematch", "nodefactor", "nodemix")) {
    model.type <- "hetero"
  } else {
    model.type <- "invalid"
  }
  if (length(d.rate) > 1) {
    stop("Length of d.rate must be 1", call. = FALSE)
  }
  # Log transformation of duration to coefficent
  if (t1.edges == FALSE) {
    stop("Dissolution models must start with offset(edges)", call. = FALSE)
  }
  if (form.length == 1) {
    if (length(duration) > 1) {
      stop("Dissolution model length is 1, but number of duration was ",
           length(duration), call. = FALSE)
    }
    pg <- (duration[1] - 1) / duration[1]
    ps2 <- (1 - d.rate) ^ 2
    if (ps2 <= pg) {
      d.rate_ <- round(1 - sqrt(pg), 5)
      str <- paste("The competing risk of departure is too high for the given",
                   " duration of ", duration[1],
                   "; specify a d.rate lower than ", d.rate_, ".", sep = "")
      stop(str, call. = FALSE)
    }

    coef.crude <- log(pg / (1 - pg))
    coef.adj <- log(pg / (ps2 - pg))
  }
  if (form.length == 2) {
    if (t2.term %in% c("nodematch", "nodefactor", "nodemix")) {
      coef.crude <- coef.adj <- NA
      for (i in 1:length(duration)) {
        pg <- (duration[i] - 1) / duration[i]
        ps2 <- (1 - d.rate) ^ 2

        if (ps2 <= pg) {
          d.rate_ <- round(1 - sqrt(pg), 5)
          stop("The competing risk of departure is too high for the given",
               " edge duration of ", duration[i], " in place ", i, ". ",
               "Specify a d.rate lower than ", d.rate_, ".", sep = "")
        }
        if (i == 1) {
          coef.crude[i] <- log(pg / (1 - pg))
          coef.adj[i] <- log(pg / (ps2 - pg))
        } else {
          coef.crude[i] <- log(pg / (1 - pg)) - coef.crude[1]
          coef.adj[i] <- log(pg / (ps2 - pg)) - coef.adj[1]
        }
      }
    } else {
      stop("Supported heterogeneous dissolution model terms are nodematch, ",
           "nodefactor, or nodemix", call. = FALSE)
    }
  }
  out <- list()
  out$dissolution <- dissolution
  out$duration <- duration
  out$coef.crude <- coef.crude
  out$coef.adj <- coef.adj
  out$d.rate <- d.rate
  out$model.type <- model.type
  class(out) <- "disscoef"
  return(out)
}


#' @title Table of Edge Censoring
#'
#' @description Outputs a table of the number and percent of edges that are
#'              left-censored, right-censored, both-censored, or uncensored for
#'              a \code{networkDynamic} object.
#'
#' @param el Timed edgelist with start and end times extracted from a
#'        \code{networkDynamic} object using the
#'        \code{as.data.frame.networkDynamic} function.
#'
#' @export
#' @keywords netUtils
#'
#' @details
#' Given a STERGM simulation over a specified number of time steps, the edges
#' within that simulation may be left-censored (started before the first step),
#' right-censored (continued after the last step), right and left-censored, or
#' uncensored. The amount of censoring will increase when the average edge
#' duration approaches the length of the simulation.
#'
#' @examples
#' # Initialize and parameterize network model
#' nw <- network_initialize(n = 100)
#' formation <- ~edges
#' target.stats <- 50
#' coef.diss <- dissolution_coefs(dissolution = ~offset(edges), duration = 20)
#'
#' # Model estimation
#' est <- netest(nw, formation, target.stats, coef.diss, verbose = FALSE)
#'
#' # Simulate the network and extract a timed edgelist
#' dx <- netdx(est, nsims = 1, nsteps = 100, keep.tedgelist = TRUE,
#'       verbose = FALSE)
#' el <- as.data.frame(dx)
#'
#' # Calculate censoring
#' edgelist_censor(el)
#'
edgelist_censor <- function(el) {
  # left censored
  leftcens <- el$onset.censored
  leftcens.num <- sum(leftcens)
  leftcens.pct <- leftcens.num / nrow(el)
  # right censored
  rightcens <- el$terminus.censored
  rightcens.num <- sum(rightcens)
  rightcens.pct <- rightcens.num / nrow(el)
  # partnership lasts for entire window (left and right censored)
  lrcens <- el$onset.censored & el$terminus.censored
  lrcens.num <- sum(lrcens)
  lrcens.pct <- lrcens.num / nrow(el)
  # fully observed
  nocens <- el$onset.censored == FALSE & el$terminus.censored == FALSE
  nocens.num <- sum(nocens)
  nocens.pct <- nocens.num / nrow(el)
  ## Table
  nums <- rbind(leftcens.num, rightcens.num, lrcens.num, nocens.num)
  pcts <- rbind(leftcens.pct, rightcens.pct, lrcens.pct, nocens.pct)
  out <- cbind(nums, pcts)
  rownames(out) <- c("Left Cens.", "Right Cens.", "Both Cens.", "No Cens.")
  colnames(out) <- c("num", "pct")
  return(out)
}


#' @title Mean Age of Partnerships over Time
#'
#' @description Outputs a vector of mean ages of edges at a series of timesteps
#'
#' @param x An \code{EpiModel} object of class \code{\link{netest}}.
#' @param el If not passing \code{x}, a timed edgelist from a
#'        \code{networkDynamic} object extracted with the
#'        \code{as.data.frame.networkDynamic} function.
#'
#' @details
#' This function calculates the mean partnership age at each time step over
#' a dynamic network simulation from \code{\link{netest}}. These objects
#' contain the network, edgelist, and dissolution objects needed for the
#' calculation. Alternatively, one may pass in these objects separately if
#' \code{netest} was not used, or statistics were not run requested after
#' the estimation.
#'
#' Currently, the calculations are limited to those dissolution formulas with a
#' single homogenous dissolution (\code{~offset(edges)}). This functionality
#' will be expanded in future releases.
#'
#' @export
#' @keywords netUtils internal
#'
#' @examples
#' # Initialize and parameterize the network model
#' nw <- network_initialize(n = 100)
#' formation <- ~edges
#' target.stats <- 50
#' coef.diss <- dissolution_coefs(dissolution = ~offset(edges), duration = 20)
#'
#' # Model estimation
#' est <- netest(nw, formation, target.stats, coef.diss, verbose = FALSE)
#'
#' # Simulate the network and extract a timed edgelist
#' dx <- netdx(est, nsims = 1, nsteps = 100, keep.tedgelist = TRUE,
#'       verbose = FALSE)
#' el <- as.data.frame(dx)
#'
#' # Calculate ages directly from edgelist
#' mean_ages <- edgelist_meanage(el = el)
#' mean_ages
#'
#' # Alternatively, netdx calculates these
#' dx$pages
#' identical(dx$pages[[1]], mean_ages)
#'
edgelist_meanage <- function(x, el) {
  # If passing a netest object directly
  if (!(missing(x))) {
    el <- x$edgelist
  }
  terminus <- el$terminus
  onset <- el$onset
  minterm <- min(terminus)
  maxterm <- max(terminus)
  meanpage <- rep(NA, maxterm)
  for (at in minterm:maxterm) {
    actp <- (onset <= at & terminus > at) |
      (onset == at & terminus == at);
    page <- at - onset[actp] + 1
    meanpage[at] <- mean(page)
  }
  meanpage <- meanpage[1:(length(meanpage) - 1)]
  return(meanpage)
}


#' @title Proportional Table of Vertex Attributes
#'
#' @description Calculates the proportional distribution of each vertex
#'              attribute contained on the network
#'
#' @param nw The \code{networkDynamic} object contained in the \code{netsim}
#'        simulation.
#' @param nwterms Vector of attributes on network object, usually as
#'        output of \code{\link{get_formula_term_attr}}.
#'
#' @seealso \code{\link{get_formula_term_attr}},
#'          \code{\link{copy_nwattr_to_datattr}},
#'          \code{\link{auto_update_attr}}.
#' @keywords netUtils internal
#' @export
#'
get_attr_prop <- function(dat, nwterms) {

  if (is.null(nwterms)) {
    return(NULL)
  }

  nwVal <- names(dat$attr)
  nwVal <- setdiff(nwVal, c("na", "vertex.names", "active", "entrTime",
                            "exitTime", "infTime", "group", "status"))
  out <- list()
  if (length(nwVal) > 0) {
    for (i in 1:length(nwVal)) {
      tab <- prop.table(table(dat$attr[[nwVal[i]]]))
      out[[i]] <- tab
    }
    names(out) <- nwVal
  }

  return(out)
}


#' @title Outputs ERGM Formula Attributes into a Character Vector
#'
#' @description Given a formation formula for a network model, outputs it into
#'              a character vector of vertex attributes to be used in
#'              \code{netsim} simulations.
#'
#' @param form an ergm model formula
#' @param nw a network object
#'
#' @export
#'
get_formula_term_attr <- function(form, nw) {

  nw_attr <- names(nw$val[[1]])
  nw_attr <- setdiff(nw_attr, c("active", "vertex.names", "na"))

  if (length(nw_attr) == 0) {
    return(NULL)
  }
  matches <- sapply(nw_attr, function(x) grepl(x, form))
  matches <- colSums(matches)

  out <- names(matches)[which(matches == 1)]
  if (length(out) == 0) {
    return(NULL)
  } else {
    return(out)
  }

}

#' @title Outputs ERGM Formula Attributes into a Character Vector
#'
#' @description Given a simulated network, outputs into
#'              a character vector of vertex attributes to be used in
#'              \code{netsim} simulations.
#'
#' @param nw a network object
#'
#' @export
#'
get_network_term_attr <- function(nw) {

  nw_attr <- names(nw$val[[1]])
  nw_attr <- setdiff(nw_attr, c("active", "vertex.names", "na",
                                "testatus.active", "tergm_pid"))

  if (length(nw_attr) == 0) {
    return(NULL)
  }

  out <- nw_attr
  if (length(out) == 0) {
    return(NULL)
  } else {
    return(out)
  }

}

#' @title Mode Numbers for Two-Group Network
#'
#' @description Outputs group numbers give ID numbers for a two-group network.
#'
#' @param nw Object of class \code{network} or \code{networkDynamic}.
#' @param ids Vector of ID numbers for which the group number
#'        should be returned.
#'
#' @export
#' @keywords netUtils internal
#'
#' @examples
#' nw <- network_initialize(n = 10)
#' nw <- set_vertex_attribute(nw, "group", rep(1:2, each = 5))
#' idgroup(nw)
#' idgroup(nw, ids = c(3, 6))
#'
idgroup <- function(nw, ids) {
  n <- network.size(nw)
  if (missing(ids)) {
    ids <- seq_len(n)
  }
  if (any(ids > n)) {
    stop("Specify ids between 1 and ", n)
  }

  flag <- "group" %in% names(nw$val[[1]])
  if (!flag) {
    out <- rep(1, n)
  } else {
    groups <- get_vertex_attribute(nw, "group")
    out <- groups[ids]
  }

  return(out)
}

#' @title Updates Vertex Attributes for Incoming Vertices
#'
#' @description Updates the vertex attributes on a network for new nodes
#'              incoming into that network, based on a set of rules for each
#'              attribute that the user specifies in \code{control.net}.
#'
#' @param dat Master object in \code{netsim} simulations.
#' @param newNodes Vector of nodal IDs for incoming nodes at the current time
#'        step.
#' @param curr.tab Current proportional distribution of all vertex attributes.
#'
#' @seealso \code{\link{copy_nwattr_to_datattr}}, \code{\link{get_attr_prop}},
#'          \code{\link{auto_update_attr}}.
#' @keywords netUtils internal
#' @export
#'
auto_update_attr <- function(dat, newNodes, curr.tab) {

  rules <- get_control(dat, "attr.rules")
  active <- get_attr(dat, "active")
  t1.tab <- dat$temp$t1.tab

  for (i in seq_along(curr.tab)) {
    vname <- names(curr.tab)[i]
    needs.updating <- ifelse(length(get_attr(dat, vname)) < length(active),
                             TRUE, FALSE)
    if (length(vname) > 0 & needs.updating == TRUE) {
      rule <- rules[[vname]]

      if (is.null(rule)) {
        rule <- "current"
      }
      if (rule == "current") {
        vclass <- class(get_attr(dat, vname))
        if (vclass == "character") {
          nattr <- sample(names(curr.tab[[vname]]),
                          size = length(newNodes),
                          replace = TRUE,
                          prob = curr.tab[[vname]])
        } else {
          nattr <- sample(as.numeric(names(curr.tab[[i]])),
                          size = length(newNodes),
                          replace = TRUE,
                          prob = curr.tab[[i]])
        }
      } else if (rule == "t1") {
        vclass <- class(get_attr(dat, vname))
        if (vclass == "character") {
          nattr <- sample(names(t1.tab[[vname]]),
                          size = length(newNodes),
                          replace = TRUE,
                          prob = t1.tab[[vname]])
        } else {
          nattr <- sample(as.numeric(names(t1.tab[[i]])),
                          size = length(newNodes),
                          replace = TRUE,
                          prob = t1.tab[[i]])
        }
      } else {
        nattr <- rep(rules[[vname]], length(newNodes))
      }
      dat$attr[[vname]] <- c(dat$attr[[vname]], nattr)
    }
  }

  return(dat)
}


#' @title Get Individual Degree from Network or Edgelist
#'
#' @description A fast method for querying the current degree of all individuals
#'              within a network.
#'
#' @param x Either an object of class \code{network} or \code{edgelist}
#'        generated from a network. If \code{x} is an edgelist, then it must
#'        contain an attribute for the total network size, \code{n}.
#'
#' @details
#' Individual-level data on the current degree of nodes within a network is
#' often useful for summary statistics and modeling complex interactions between
#' degree. Given a \code{network} class object, \code{net}, one way to look
#' up the current degree is to get a summary of the ERGM term, \code{sociality},
#' as in: \code{summary(net ~ sociality(nodes = NULL))}. But that is
#' computationally inefficient for a number of reasons. This function provide a
#' fast method for generating the vector of degree using a query of the
#' edgelist. t is even faster if the parameter \code{x} is already transformed
#' as an edgelist.
#'
#' @export
#'
#' @examples
#' nw <- network_initialize(n = 500)
#'
#' set.seed(1)
#' fit <- ergm(nw ~ edges, target.stats = 250)
#' sim <- simulate(fit)
#'
#' # Slow ERGM-based method
#' ergm.method <- unname(summary(sim ~ sociality(nodes = NULL)))
#' ergm.method
#'
#' # Fast tabulate method with network object
#' deg.net <- get_degree(sim)
#' deg.net
#'
#' # Even faster if network already transformed into an edgelist
#' el <- as.edgelist(sim)
#' deg.el <- get_degree(el)
#' deg.el
#'
#' identical(as.integer(ergm.method), deg.net, deg.el)
#'
get_degree <- function(x) {
  if (inherits(x, "network")) {
    x <- as.edgelist(x)
  }
  if (is.null(attr(x, "n"))) {
    stop("x missing an n attribute")
  }
  n <- attr(x, "n")
  out <- tabulate(x, nbins = n)
  return(out)
}


#' @title Truncate Simulation Time Series
#'
#' @description Left-truncates a simulation epidemiological summary statistics
#'              and network statistics at a specified time step.
#'
#' @param x Object of class \code{netsim} or \code{icm}.
#' @param at Time step at which to left-truncate the time series.
#'
#' @details
#' This function would be used when running a follow-up simulation from time
#' steps \code{b} to \code{c} after a burnin period from time \code{a} to
#' \code{b}, where the final time window of interest for data analysis is
#' \code{b} to \code{c} only.
#'
#' @export
#'
#' @examples
#' param <- param.icm(inf.prob = 0.2, act.rate = 0.25)
#' init <- init.icm(s.num = 500, i.num = 1)
#' control <- control.icm(type = "SI", nsteps = 200, nsims = 1)
#' mod1 <- icm(param, init, control)
#' df <- as.data.frame(mod1)
#' print(df)
#' plot(mod1)
#' mod1$control$nsteps
#'
#' mod2 <- truncate_sim(mod1, at = 150)
#' df2 <- as.data.frame(mod2)
#' print(df2)
#' plot(mod2)
#' mod2$control$nsteps
#'
truncate_sim <- function(x, at) {
  if (class(x) != "icm" && class(x) != "netsim") {
    stop("x must be either an object of class icm or class netsim",
         call. = FALSE)
  }
  rows <- at:(x$control$nsteps)
  # epi
  x$epi <- lapply(x$epi, function(r) r[rows, ])
  # control settings
  x$control$start <- 1
  x$control$nsteps <- max(seq_along(rows))
  return(x)
}
